"
A helper to spawn a subprocess launched with a custom configuration (working directory,
stdin/stdout/stderr destionation...).

See https://docs.gtk.org/gio/class.SubprocessLauncher.html
"
Class {
	#name : 'GSubprocessLauncher',
	#superclass : 'GBaseObject',
	#instVars : [
		'pipeFlags'
	],
	#traits : 'GLibIOTLibrary',
	#classTraits : 'GLibIOTLibrary classTrait',
	#pools : [
		'GObjectTypes',
		'GSubprocessFlags'
	],
	#category : 'GLib-IO-Process',
	#package : 'GLib-IO',
	#tag : 'Process'
}

{ #category : 'finalization' }
GSubprocessLauncher class >> finalizeResourceData: handle [
	"when marking for autoRelease, g-objects needs to be freed in a particular way."

	(self isValidHandle: handle) ifFalse: [ ^ self ].

	GFinalizeAnnouncement emitTarget: self handle: handle.
	GRunLoop defer: [ self gObjectUnref: handle ].
	handle beNull
]

{ #category : 'private' }
GSubprocessLauncher class >> gObjectUnref: handle [

	self ffiCall: #(void g_object_unref (void *handle)) module: GObjectLibrary
]

{ #category : 'instance creation' }
GSubprocessLauncher class >> newWithFlags: aFlags [

	^ self fromHandleUnreferenced: (self gSubprocessLauncherNew: aFlags asInteger)
]

{ #category : 'private' }
GSubprocessLauncher class >> gSubprocessLauncherNew: aFlags [

	^ self ffiCall: #(void * g_subprocess_launcher_new (gint aFlags))
]

{ #category : 'private' }
GSubprocessLauncher >> gSpawnv: argv error: errorHolder [

	self ffiCall: #(void * g_subprocess_launcher_spawnv (self, "const gchar *const *"void *argv, "GError **"GErrorHolder errorHolder)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocessLauncher >> gSubprocessSetCwd: cwd [

	self ffiCall: #(void g_subprocess_launcher_set_cwd (self, const gchar *cwd)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocessLauncher >> gSubprocessSetFlags: flags [

	self ffiCall: #(void g_subprocess_launcher_set_flags (self, gint flags)) module: GLibIOLibrary
]

{ #category : 'accessing' }
GSubprocessLauncher >> release [

	self ffiCall: #(void g_object_unref (self)) module: GObjectLibrary
]

{ #category : 'private - running' }
GSubprocessLauncher >> setCwd: aDirectory [

	aDirectory ifNotNil: [ self gSubprocessSetCwd: aDirectory ]
]

{ #category : 'private - running' }
GSubprocessLauncher >> setStderrPipe [

	self setFlags: 16 "G_SUBPROCESS_FLAGS_STDERR_PIPE"
]

{ #category : 'private - running' }
GSubprocessLauncher >> setStdinPipe [

	self setFlags: 1 "G_SUBPROCESS_FLAGS_STDIN_PIPE"
]

{ #category : 'private - running' }
GSubprocessLauncher >> setStdoutPipe [

	self setFlags: 4 "G_SUBPROCESS_FLAGS_STDOUT_PIPE"
]

{ #category : 'private - running' }
GSubprocessLauncher >> setFlags: aFlag [
	"Accumulate a GSubprocessFlags bit (an integer) into the launcher. The combined
	 flags are applied right before the process is spawned via g_subprocess_launcher_set_flags."

	self pipeFlags: (self pipeFlags bitOr: aFlag)
]

{ #category : 'private - running' }
GSubprocessLauncher >> applyPipeFlags [

	self gSubprocessSetFlags: self pipeFlags
]

{ #category : 'private - running' }
GSubprocessLauncher >> spawn: command arguments: arguments error: errorHolder [

	| argv process |
	self applyPipeFlags.
	argv := ExternalAddress arrayOfStringsFrom: { command } , arguments.
	^ [ process := self gSpawnv: argv error: errorHolder.
		(process isNil or: [ process isNull ])
			ifTrue: [ nil ]
			ifFalse: [ GSubprocess fromHandleUnreferenced: process ] ]
		ensure: [ argv freeArrayOfStrings ]
]

{ #category : 'private - running' }
GSubprocessLauncher >> pipeFlags [

	^ pipeFlags ifNil: [ pipeFlags := 0 ]
]

{ #category : 'private - running' }
GSubprocessLauncher >> pipeFlags: anInteger [

	pipeFlags := anInteger
]
