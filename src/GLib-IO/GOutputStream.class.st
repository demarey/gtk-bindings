"
I am a base class for stream-oriented output. In the SubProcess context I wrap the
stdin pipe of a GSubprocess and expose blocking writes.

See https://docs.gtk.org/gio/class.OutputStream.html
"
Class {
	#name : 'GOutputStream',
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
GOutputStream class >> finalizeResourceData: handle [
	"when marking for autoRelease, g-objects needs to be freed in a particular way."

	(self isValidHandle: handle) ifFalse: [ ^ self ].

	GFinalizeAnnouncement emitTarget: self handle: handle.
	GRunLoop defer: [ self gObjectUnref: handle ].
	handle beNull
]

{ #category : 'private' }
GOutputStream class >> gObjectUnref: handle [

	self ffiCall: #(void g_object_unref (void *handle)) module: GObjectLibrary
]

{ #category : 'private' }
GOutputStream >> gOutputStreamWriteAll: buffer count: count bytesWritten: bytesWritten cancellable: cancellable error: error [

	^ self ffiCall: #(gboolean g_output_stream_write_all (
		self,
		const gchar *buffer,
		gsize count,
		"gsize *"void *bytesWritten,
		"GCancellable *"gpointer cancellable,
		"GError **"GErrorHolder error)) module: GLibIOLibrary
]

{ #category : 'private' }
GOutputStream >> gOutputStreamClose: cancellable error: error [

	^ self ffiCall: #(gboolean g_output_stream_close (self, "GCancellable *"gpointer cancellable, "GError **"GErrorHolder error)) module: GLibIOLibrary
]

{ #category : 'accessing' }
GOutputStream >> close [

	self gOutputStreamClose: ExternalAddress null error: GErrorHolder new
]

{ #category : 'accessing' }
GOutputStream >> release [

	self ffiCall: #(void g_object_unref (self)) module: GObjectLibrary
]

{ #category : 'accessing' }
GOutputStream >> write: aString [
	"Write aString to the stream, blocking until all bytes have been written."

	| count bytesWritten error |
	error := GErrorHolder new.
	bytesWritten := FFISizeT newBuffer.
	count := (aString asByteArray) size.
	self gOutputStreamWriteAll: aString count: count bytesWritten: bytesWritten cancellable: ExternalAddress null error: error.
	^ count
]

{ #category : 'accessing' }
GOutputStream >> writeFlush: aString [
	"GOutputStream writes are synchronous, so writing is equivalent to write-then-flush."

	^ self write: aString
]
