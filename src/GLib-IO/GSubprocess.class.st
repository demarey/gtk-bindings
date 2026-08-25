"
I represent a child process spawned with the GSubprocess API. I offer access to the
child's exit status and, when configured so, to its stdin/stdout/stderr pipes.

See https://docs.gtk.org/gio/class.Subprocess.html
"
Class {
	#name : 'GSubprocess',
	#superclass : 'GBaseObject',
	#traits : 'GLibIOTLibrary',
	#classTraits : 'GLibIOTLibrary classTrait',
	#pools : [
		'GObjectTypes'
	],
	#category : 'GLib-IO-Process',
	#package : 'GLib-IO',
	#tag : 'Process'
}

{ #category : 'finalization' }
GSubprocess class >> finalizeResourceData: handle [
	"when marking for autoRelease, g-objects needs to be freed in a particular way."

	(self isValidHandle: handle) ifFalse: [ ^ self ].

	GFinalizeAnnouncement emitTarget: self handle: handle.
	GRunLoop defer: [ self gObjectUnref: handle ].
	handle beNull
]

{ #category : 'private' }
GSubprocess class >> gObjectUnref: handle [

	self ffiCall: #(void g_object_unref (void *handle)) module: GObjectLibrary
]

{ #category : 'private' }
GSubprocess >> gCommunicate: stdinBytes cancellable: cancellable stdout: stdoutHolder stderr: stderrHolder error: errorHolder [

	self ffiCall: #(gboolean g_subprocess_communicate (
		self,
		GBytes *stdinBytes,
		"GCancellable *"gpointer cancellable,
		"GBytes **"gpointerHolder stdoutHolder,
		"GBytes **"gpointerHolder stderrHolder,
		"GError **"GErrorHolder errorHolder)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocess >> gForceExit [

	self ffiCall: #(void g_subprocess_force_exit (self)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocess >> gGetExitStatus [

	^ self ffiCall: #(gint g_subprocess_get_exit_status (self)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocess >> gGetIdentifier [

	^ self ffiCall: #(gchar* g_subprocess_get_identifier (self)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocess >> gGetStderrPipe [

	^ self ffiCall: #(GInputStream* g_subprocess_get_stderr_pipe (self)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocess >> gGetStdinPipe [

	^ self ffiCall: #(GOutputStream* g_subprocess_get_stdin_pipe (self)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocess >> gGetStdoutPipe [

	^ self ffiCall: #(GInputStream* g_subprocess_get_stdout_pipe (self)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocess >> gGetSuccessful [

	^ self ffiCall: #(gboolean g_subprocess_get_successful (self)) module: GLibIOLibrary
]

{ #category : 'private' }
GSubprocess >> gWait: cancellable error: errorHolder [

	^ self ffiCall: #(gboolean g_subprocess_wait (self, "GCancellable *"gpointer cancellable, "GError **"GErrorHolder errorHolder)) module: GLibIOLibrary
]

{ #category : 'accessing' }
GSubprocess >> communicate [
	"Run the process to completion, feeding no data to stdin and answering a
	 dictionary with #stdOut/#stdErr as GBytes. Blocks until the child exits."

	| stdoutHolder stderrHolder error |
	stdoutHolder := gpointerHolder new.
	stderrHolder := gpointerHolder new.
	error := GErrorHolder new.
	self gCommunicate: ExternalAddress null cancellable: ExternalAddress null stdout: stdoutHolder stderr: stderrHolder error: error.
	^ { #stdOut -> stdoutHolder value. #stdErr -> stderrHolder value } asDictionary
]

{ #category : 'accessing' }
GSubprocess >> exitStatus [

	^ self gGetExitStatus
]

{ #category : 'accessing' }
GSubprocess >> forceExit [

	self gForceExit
]

{ #category : 'accessing' }
GSubprocess >> pid [

	^ self gGetIdentifier
		ifNil: [ 0 ]
		ifNotNil: [ :id | id asInteger ]
]

{ #category : 'accessing' }
GSubprocess >> release [

	self ffiCall: #(void g_object_unref (self)) module: GObjectLibrary
]

{ #category : 'accessing' }
GSubprocess >> stderrPipe [

	^ self gGetStderrPipe
]

{ #category : 'accessing' }
GSubprocess >> stdinPipe [

	^ self gGetStdinPipe
]

{ #category : 'accessing' }
GSubprocess >> stdoutPipe [

	^ self gGetStdoutPipe
]

{ #category : 'testing' }
GSubprocess >> successful [

	^ self gGetSuccessful
]

{ #category : 'accessing' }
GSubprocess >> wait [
	"Block until the child process exits, then answer self."

	self gWait: ExternalAddress null error: GErrorHolder new.
	^ self
]
