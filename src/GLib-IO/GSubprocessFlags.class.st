"
enum GSubprocessFlags

Flags to define the behaviour of a GSubprocess. Note that the default for stdin is
to inherit from the parent process.
"
Class {
	#name : 'GSubprocessFlags',
	#superclass : 'GEnumeration',
	#classVars : [
		'G_SUBPROCESS_FLAGS_NONE',
		'G_SUBPROCESS_FLAGS_STDERR_INHERIT',
		'G_SUBPROCESS_FLAGS_STDERR_MERGE',
		'G_SUBPROCESS_FLAGS_STDERR_PIPE',
		'G_SUBPROCESS_FLAGS_STDIN_INHERIT',
		'G_SUBPROCESS_FLAGS_STDIN_PIPE',
		'G_SUBPROCESS_FLAGS_STDOUT_INHERIT',
		'G_SUBPROCESS_FLAGS_STDOUT_PIPE'
	],
	#category : 'GLib-IO-Process',
	#package : 'GLib-IO',
	#tag : 'Process'
}

{ #category : 'accessing enum' }
GSubprocessFlags class >> G_SUBPROCESS_FLAGS_NONE [
	"This method was automatically generated"
	^ G_SUBPROCESS_FLAGS_NONE
]

{ #category : 'accessing enum' }
GSubprocessFlags class >> G_SUBPROCESS_FLAGS_STDERR_INHERIT [
	"This method was automatically generated"
	^ G_SUBPROCESS_FLAGS_STDERR_INHERIT
]

{ #category : 'accessing enum' }
GSubprocessFlags class >> G_SUBPROCESS_FLAGS_STDERR_MERGE [
	"This method was automatically generated"
	^ G_SUBPROCESS_FLAGS_STDERR_MERGE
]

{ #category : 'accessing enum' }
GSubprocessFlags class >> G_SUBPROCESS_FLAGS_STDERR_PIPE [
	"This method was automatically generated"
	^ G_SUBPROCESS_FLAGS_STDERR_PIPE
]

{ #category : 'accessing enum' }
GSubprocessFlags class >> G_SUBPROCESS_FLAGS_STDIN_INHERIT [
	"This method was automatically generated"
	^ G_SUBPROCESS_FLAGS_STDIN_INHERIT
]

{ #category : 'accessing enum' }
GSubprocessFlags class >> G_SUBPROCESS_FLAGS_STDIN_PIPE [
	"This method was automatically generated"
	^ G_SUBPROCESS_FLAGS_STDIN_PIPE
]

{ #category : 'accessing enum' }
GSubprocessFlags class >> G_SUBPROCESS_FLAGS_STDOUT_INHERIT [
	"This method was automatically generated"
	^ G_SUBPROCESS_FLAGS_STDOUT_INHERIT
]

{ #category : 'accessing enum' }
GSubprocessFlags class >> G_SUBPROCESS_FLAGS_STDOUT_PIPE [
	"This method was automatically generated"
	^ G_SUBPROCESS_FLAGS_STDOUT_PIPE
]

{ #category : 'enum declaration' }
GSubprocessFlags class >> enumDecl [
	"
	self initializeEnumeration.
	self rebuildEnumAccessors 
	"

	^ { 
		#G_SUBPROCESS_FLAGS_NONE           . 0.
		#G_SUBPROCESS_FLAGS_STDIN_PIPE     . 1.
		#G_SUBPROCESS_FLAGS_STDIN_INHERIT  . 2.
		#G_SUBPROCESS_FLAGS_STDOUT_PIPE    . 4.
		#G_SUBPROCESS_FLAGS_STDOUT_INHERIT . 8.
		#G_SUBPROCESS_FLAGS_STDERR_PIPE    . 16.
		#G_SUBPROCESS_FLAGS_STDERR_INHERIT . 32.
		#G_SUBPROCESS_FLAGS_STDERR_MERGE   . 64
	 }
]
