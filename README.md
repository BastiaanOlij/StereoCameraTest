# StereoCameraTest
Godot project file to test stereoscopic rendering additions to Godot

These files presented here are for testing and demonstrating the asymmetrical camera logic I'm attempting to add to Godot.
For this to work you will need the enhancement added to my fork of the godot source code that can be found here:
https://github.com/BastiaanOlij/godot
Unless by the time you read this these changes have ended up in the official Godot release (I can dream can't I:) ) you'll need to build Godot with my changes added in to use this.

As a starting point I've used Lamberto Tedaldi (www.officinepixel.com) pure Godot implementation but it has a few limitations that can't be overcome without diving into the C++ code. For reference I have included a slightly modified version of his plugin in this repository to see how my changes would be applied to his tracking logic.

At this point in time this is still very early work with just the enhancements made to use an assymetrical camera and I'm pretty sure I've missed a few things seeing I'm relatively new to Godot. I haven't tested out shadows or anything like that.

I'll keep updating this thread on the godot forums on the status of this project and give some more detail about the changes made:
https://godotdevelopers.org/forum/discussion/17793/stereoscopic-rendering

Hope you enjoy this.

Bastiaan Olij
