Class {
	#name : #GEnumeration,
	#superclass : #FFIExternalEnumeration,
	#category : #'GObject-Base'
}

{ #category : #private }
GEnumeration class >> newValue: anInteger [
	"Used for aritmetic"

	^ self basicNew 
		initialize;
		value: anInteger;
		yourself
]

{ #category : #accessing }
GEnumeration class >> systemIconName [

	^ #magnitude
]

{ #category : #'logical operations' }
GEnumeration >> & other [

	^ self class newValue: self value & other value
]

{ #category : #arithmetic }
GEnumeration >> + other [

	^ self class newValue: (self value + other value)
]

{ #category : #arithmetic }
GEnumeration >> - other [

	^ self class newValue: (self value - other value)
]

{ #category : #'logical operations' }
GEnumeration >> | other [

	^ self class newValue: self value | other value
]
