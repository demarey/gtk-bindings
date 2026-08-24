"
An object to wrap the output of a GSpawn
"
Class {
	#name : 'GIOProcess',
	#superclass : 'Object',
	#traits : 'GLibTLibrary',
	#classTraits : 'GLibTLibrary classTrait',
	#instVars : [
		'pid',
		'callbacks',
		'watchSource'
	],
	#pools : [
		'GObjectTypes',
		'GSpawnFlags'
	],
	#category : 'GLib-IO-Process',
	#package : 'GLib-IO',
	#tag : 'Process'
}

{ #category : 'private' }
GIOProcess class >> gSpawnAsync: working_directory argv: argv envp: envp flags: flags childSetup: child_setup data: user_data [
	| gPidOut error result |

	gPidOut := FFIInt32 newBuffer.
	error := GErrorHolder new.	
	
	result := self 
		gSpawnAsync: working_directory 
		argv: argv
		envp: envp
		flags: flags 
		childSetup: child_setup 
		data: user_data 
		childPidOut: gPidOut 
		error: error.

	result ifFalse: [ 
		self error: error value messageString ].
	
	^ self basicNew 
		initializePid: (gPidOut signedLongAt: 1);
		yourself
]

{ #category : 'private' }
GIOProcess class >> gSpawnAsync: working_directory argv: argv envp: envp flags: flags childSetup: child_setup data: user_data childPidOut: child_pid_out error: error [
	"void (*GSpawnChildSetupFunc) (gpointer user_data)"

	self ffiCall: #(gboolean g_spawn_async (
		const gchar *working_directory,
		"const gchar **"void *argv,
 		"const gchar **"void *envp,
		GSpawnFlags flags,
 		"GSpawnChildSetupFunc "void *child_setup,
		gpointer user_data,
		"GPid *"void *child_pid_out,
		"GError **"GErrorHolder error))
]

{ #category : 'private' }
GIOProcess class >> gSpawnAsync: working_directory command: command arguments: anArray flags: flags childSetup: child_setup data: user_data [
	| argv envp |

	envp := ExternalAddress null.
	argv := ExternalAddress arrayOfStringsFrom: { command }, anArray.
	^ [
			self 
				gSpawnAsync: working_directory 
				argv: argv 
				envp: envp 
				flags: flags 
				childSetup: child_setup 
				data: user_data ]
		ensure: [ 
			argv freeArrayOfStrings ]
]

{ #category : 'private' }
GIOProcess class >> decodeExitCodeFromWaitStatus: waitStatusValue [
	"On POSIX, the wait status packs the exit code into bits 8-15 (WEXITSTATUS),
	 which is only valid when the process exited normally (WIFEXITED). On Windows
	 the wait status already is the exit code."

	| terminationStatus exitCode |

	OSPlatform current isWindows ifTrue: [ ^ waitStatusValue ].

	terminationStatus := waitStatusValue bitAnd: 16r7F.
	terminationStatus isZero ifFalse: [ ^ nil ].

	exitCode := (waitStatusValue bitShift: -8) bitAnd: 16rFF.
	^ exitCode
]

{ #category : 'private' }
GIOProcess class >> gSpawnCheckWaitStatus: waitStatus error: error [
	" see https://docs.gtk.org/glib/func.spawn_check_wait_status.html
	gboolean g_spawn_check_wait_status (gint wait_status, GError** error) "

	self ffiCall: #(gboolean g_spawn_check_wait_status (
		const gint wait_status,
		"GError **"gpointerHolder error))
]

{ #category : 'instance creation' }
GIOProcess class >> spawn: command [

	^ self spawn: command flags: G_SPAWN_DEFAULT
]

{ #category : 'instance creation' }
GIOProcess class >> spawn: command arguments: anArray [

	^ self 
		spawn: command 
		arguments: anArray
		flags: G_SPAWN_DEFAULT
]

{ #category : 'instance creation' }
GIOProcess class >> spawn: command arguments: anArray flags: flags [

	^ self 
		spawn: command 
		arguments: anArray 
		workingDirectory: nil 
		flags: flags
]

{ #category : 'instance creation' }
GIOProcess class >> spawn: command arguments: anArray workingDirectory: workingDir flags: flags [ 

	^ self 
		gSpawnAsync: workingDir 
		command: command 
		arguments: anArray 
		flags: flags 
		childSetup: ExternalAddress null 
		data: ExternalAddress null
]

{ #category : 'instance creation' }
GIOProcess class >> spawn: command flags: flags [

	^ self spawn: command arguments: #() flags: flags
]

{ #category : 'accessing' }
GIOProcess >> close [

	self gSpawnClose
]

{ #category : 'private' }
GIOProcess >> gChildWatchAdd: function [

	^ self ffiCall: #(guint 
		g_child_watch_add (
  		"GPid"int pid,
  		"GChildWatchFunc"GCallback function,
  		"gpointer data"NULL))

]

{ #category : 'private' }
GIOProcess >> gSpawnClose [

	^ self ffiCall: #(void g_spawn_close_pid (GPid pid))
]

{ #category : 'initialization' }
GIOProcess >> initializePid: pidNum [

	self initialize.
	pid := pidNum. 
	"self watch: [ :status | self close ]"
]

{ #category : 'accessing' }
GIOProcess >> pid [

	^ pid
]

{ #category : 'accessing' }
GIOProcess >> watch: aBlock [ 
	"Add a child watch block which will be called when the child process exits,
	 attached to the default GMainContext (see #watch:in:)."

	^ self watch: aBlock in: GMainContext default
]

{ #category : 'accessing' }
GIOProcess >> watch: aBlock in: aContext [
	"Add a child watch block which will be called when the child process exits.
	 GLib supports only a single callback per process id.
	 The child watch source is ATTACHED to aContext, so the process handle is only ever
	 polled there. Pass a dedicated private GMainContext to avoid racing with threads that
	 iterate the shared default context (see GSubprocess, gio/gsubprocess.c). If the process
	 is spawned with other value than default, you may need to watch it to properly close it
	 (see g_spawn documentation and examples)."
	| callback source |

	callback := GCallback 
		signature: #(void (GPid pidNum, gint wait_status, gpointer user_data)) 
		block: [ :pidNum :status :data | aBlock value: status ]. 
	callbacks ifNil: [ callbacks := Set new ].
	callbacks add: callback.
	source := self gChildWatchSourceNew.
	self gSourceSetCallback: source function: callback.
	self gSourceAttach: source context: aContext.
	"Keep our own reference on the GSource (in addition to the context's) so we can safely
	 detach it later via #removeChildWatch using g_source_destroy + g_source_unref on the
	 pointer, instead of a numeric source id which GLib may reuse/reset across engine
	 restarts (g_source_remove: on a stale id emits 'Source ID ... was not found')."
	watchSource := source
]

{ #category : 'accessing' }
GIOProcess >> removeChildWatch [
	"Detach the child watch source (if any) from its GMainContext so the process handle is
	 no longer polled. Should be called before closing the pid on a premature #terminate;
	 after a normal exit the source is destroyed automatically by the main context.
	 g_source_destroy is a safe no-op if the source already fired (one-shot), so this can be
	 called from both the completion and terminate paths."

	watchSource ifNil: [ ^ self ].
	self gSourceDestroy: watchSource.
	self gSourceUnref: watchSource.
	watchSource := nil
]

{ #category : 'private' }
GIOProcess >> gChildWatchSourceNew [

	^ self ffiCall: #("GSource"void * g_child_watch_source_new ("GPid"int pid))
]

{ #category : 'private' }
GIOProcess >> gSourceAttach: source context: context [

	^ self ffiCall: #(guint g_source_attach ("GSource"void *source, GMainContext *context))
]

{ #category : 'private' }
GIOProcess >> gSourceDestroy: source [

	self ffiCall: #(void g_source_destroy ("GSource"void *source))
]

{ #category : 'private' }
GIOProcess >> gSourceSetCallback: source function: function [

	self ffiCall: #(void g_source_set_callback (
		"GSource"void *source,
		"GSourceFunc"gpointer function,
		NULL,
		NULL))
]

{ #category : 'private' }
GIOProcess >> gSourceUnref: source [

	self ffiCall: #(void g_source_unref ("GSource"void *source))
]
