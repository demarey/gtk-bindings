"
I'm a system for reporting errors.

https://developer.gnome.org/glib/stable/glib-Error-Reporting.html
"
Class {
	#name : #GError,
	#superclass : #GStructure,
	#classVars : [
		'OFFSET_CODE',
		'OFFSET_DOMAIN',
		'OFFSET_MESSAGE'
	],
	#pools : [
		'GtkTypes'
	],
	#category : #'GObject-Misc'
}

{ #category : #'field definition' }
GError class >> fieldsDesc [
	"self rebuildFieldAccessors" 
	^ #(
	GQuark       domain;
  	gint         code;
  	gchar       *message
	)
]

{ #category : #'accessing structure variables' }
GError >> code [
	"This method was automatically generated"
	^handle signedLongAt: OFFSET_CODE
]

{ #category : #'accessing structure variables' }
GError >> code: anObject [
	"This method was automatically generated"
	handle signedLongAt: OFFSET_CODE put: anObject
]

{ #category : #'accessing structure variables' }
GError >> domain [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_DOMAIN
]

{ #category : #'accessing structure variables' }
GError >> domain: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_DOMAIN put: anObject
]

{ #category : #accessing }
GError >> domainString [
	^ self gquarkToString: self domain
]

{ #category : #freeing }
GError >> free [
	"Frees a GError and associated resources."

	self g_error_free.
	handle := nil.
]

{ #category : #freeing }
GError >> g_error_free [
	"Frees a GError and associated resources.
	void g_error_free (GError* error)"

	self ffiCall: #(void g_error_free(self) ) module: GLibLibrary.
]

{ #category : #private }
GError >> gquarkToString: quark [

	^ self ffiCall: #(const gchar *g_quark_to_string (GQuark quark)) module: GLibLibrary
]

{ #category : #testing }
GError >> isError [
	^ self isOk not
]

{ #category : #testing }
GError >> isOk [
	^ self code = 0
]

{ #category : #'accessing structure variables' }
GError >> message [
	"This method was automatically generated"
	^ExternalData fromHandle: (handle pointerAt: OFFSET_MESSAGE) type: ExternalType char asPointerType
]

{ #category : #'accessing structure variables' }
GError >> message: anObject [
	"This method was automatically generated"
	handle pointerAt: OFFSET_MESSAGE put: anObject getHandle.
]

{ #category : #accessing }
GError >> messageString [

	self message isNull ifTrue: [ ^ 'Unknown error.' ].
	^ self message bytesFromCString
]
