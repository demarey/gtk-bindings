Class {
	#name : 'GMainContext',
	#superclass : 'GBaseObject',
	#traits : 'GLibTLibrary',
	#classTraits : 'GLibTLibrary classTrait',
	#category : 'GLib-Application',
	#package : 'GLib',
	#tag : 'Application'
}

	{ #category : 'instance creation' }
GMainContext class >> new [

	"Create a NEW dedicated GMainContext. Used to isolate a child watch (and its process
	 handle) from the shared default context, mirroring how GIO's GSubprocess attaches its
	 child watch to a private worker context."

	^ self ffiCall: #(GMainContext* g_main_context_new (void))
]

	{ #category : 'accessing' }
GMainContext class >> default [

	^ self ffiCall: #(GMainContext* g_main_context_default (void))
]

{ #category : 'events - processing' }
GMainContext class >> iteration: may_block [

	^ self ffiCall: #(gboolean g_main_context_iteration (NULL, gboolean may_block))
]

{ #category : 'acccessing' }
GMainContext >> acquire [

	self ffiCall: #(gboolean g_main_context_acquire (self))
]

{ #category : 'testing' }
GMainContext >> hasPendingEvents [

	^ self ffiCall: #(gboolean g_main_context_pending (self))
]

{ #category : 'events - processing' }
GMainContext >> iteration: may_block [

	^ self ffiCall: #(gboolean g_main_context_iteration (self, gboolean may_block))
]

{ #category : 'acccessing' }
GMainContext >> release [

	self ffiCall: #(void g_main_context_release (self))
]

{ #category : 'acccessing' }
GMainContext >> wakeup [

	self ffiCall: #(void g_main_context_wakeup (self))
]
