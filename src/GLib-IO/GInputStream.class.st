"
I am a base class for stream-oriented input. In the SubProcess context I wrap the
stdout/stderr pipes of a GSubprocess and expose blocking reads.

See https://docs.gtk.org/gio/class.InputStream.html
"
Class {
	#name : 'GInputStream',
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
GInputStream class >> finalizeResourceData: handle [
	"when marking for autoRelease, g-objects needs to be freed in a particular way."

	(self isValidHandle: handle) ifFalse: [ ^ self ].

	GFinalizeAnnouncement emitTarget: self handle: handle.
	GRunLoop defer: [ self gObjectUnref: handle ].
	handle beNull
]

{ #category : 'private' }
GInputStream class >> gObjectUnref: handle [

	self ffiCall: #(void g_object_unref (void *handle)) module: GObjectLibrary
]

{ #category : 'accessing' }
GInputStream >> canPoll [

	^ self gPollableCanPoll
]

{ #category : 'private' }
GInputStream >> gPollableCanPoll [

	^ self ffiCall: #(gboolean g_pollable_input_stream_can_poll (self)) module: GLibIOLibrary
]

{ #category : 'private' }
GInputStream >> gInputStreamRead: buffer count: count cancellable: cancellable error: error [

	^ self ffiCall: #(gssize g_input_stream_read (self, gchar *buffer, gsize count, "GCancellable *"gpointer cancellable, "GError **"GErrorHolder error)) module: GLibIOLibrary
]

{ #category : 'private' }
GInputStream >> gInputStreamClose: cancellable error: error [

	^ self ffiCall: #(gboolean g_input_stream_close (self, "GCancellable *"gpointer cancellable, "GError **"GErrorHolder error)) module: GLibIOLibrary
]

{ #category : 'accessing' }
GInputStream >> close [

	self gInputStreamClose: ExternalAddress null error: GErrorHolder new
]

{ #category : 'accessing' }
GInputStream >> read: count [
	"Read up to count bytes, blocking until data is available or the stream is at EOF.
	 Answer a ByteArray with the bytes actually read; an empty ByteArray at EOF."

	| buf error n |
	error := GErrorHolder new.
	buf := ByteArray new: count.
	n := self gInputStreamRead: buf count: count cancellable: ExternalAddress null error: error.
	n <= 0 ifTrue: [ ^ ByteArray new: 0 ].
	^ buf first: n
]

{ #category : 'accessing' }
GInputStream >> readOneByte [
	| chunk |
	chunk := self read: 1.
	^ chunk isEmpty ifTrue: [ nil ] ifFalse: [ chunk first ]
]

{ #category : 'accessing' }
GInputStream >> readLineEncoded: anEncoding [
	"Read the next line (the bytes up to and excluding a trailing LF, CR or CRLF
	 terminator), decode them with anEncoding and answer it as a String. Answer nil
	 at end of stream."

	| bytes b |
	bytes := WriteStream on: ByteArray new.
	[ (b := self readOneByte) isNil ] whileFalse: [
		(b = 13 or: [ b = 10 ]) ifTrue: [
			b = 13 ifTrue: [ | nb | nb := self readOneByte. nb = 10 ifFalse: [ ] ].
			^ bytes contents decodeWith: anEncoding ].
		bytes nextPut: b ].
	^ bytes isEmpty ifTrue: [ nil ] ifFalse: [ bytes contents decodeWith: anEncoding ]
]

{ #category : 'accessing' }
GInputStream >> isPollableReadable [
	"Answer true if reading now would not block (data is available, or the stream is at EOF)."

	^ self gPollableIsReadable
]

{ #category : 'private' }
GInputStream >> gPollableIsReadable [

	^ self ffiCall: #(gboolean g_pollable_input_stream_is_readable (self)) module: GLibIOLibrary
]

{ #category : 'accessing' }
GInputStream >> readNonBlocking: count [
	"Read up to count bytes without blocking the VM thread when there is no data. Answer:
	 - nil if no data is currently available (reading would block),
	 - an empty ByteArray at end of stream,
	 - otherwise a ByteArray with the bytes read.
	 Uses the pollable is_readable check to decide whether an immediate blocking read is safe."

	^ (self canPoll and: [ self isPollableReadable ])
		ifFalse: [ nil ]
		ifTrue: [ self read: count ]
]

{ #category : 'accessing' }
GInputStream >> readLine [
	"Answer the next line decoded as a UTF-8 String, or nil at end of stream."

	^ self readLineEncoded: 'utf8'
]

{ #category : 'accessing' }
GInputStream >> readAllInto: aWriteStream [
	"Read everything until EOF, appending each chunk to aWriteStream. Blocks until EOF."

	[ | chunk |
	  chunk := self read: 4096.
	  chunk isEmpty ifTrue: [ ^ aWriteStream ].
	  aWriteStream nextPutAll: chunk ] repeat
]

{ #category : 'accessing' }
GInputStream >> release [

	self ffiCall: #(void g_object_unref (self)) module: GObjectLibrary
]
