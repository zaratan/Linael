Linael
======
[![Code Climate](https://codeclimate.com/github/Skizzk/Linael.png)](https://codeclimate.com/github/Skizzk/Linael)
[![Dependency Status](https://gemnasium.com/Skizzk/Linael.png)](https://gemnasium.com/Skizzk/Linael)

Modular collaborative IRC Bot in Ruby. 

#What is Linael and why Linael?

* Linael is a modular collaborative IRC bot written in ruby.
> **Modular** because the core functionnality is the module plugger (which is himself a module).
> **Collaborative** because i'll happyly integrate any module you will submit :)

* She is designed to hot load/reload modules so you don't have to stop her... EVER.
> Seriously, you **don't** really want your bot to quit for adding/correcting a functionnality.

* It's shipped with a DSL to make module writting easy.
> Just tell your bot what you want to do. Do not ask yourself how to.

* It come with an ever-growing library of modules.
> You want to create, not to rewrite the same old administration module, don't you?




##What is not Linael (and why not Cinch)

It's not a gem. You can't add it to an other program this easily. And it is a bit heavier to clone the whole directory.

It's not only a framework to build features. 
It's a whole bot with embeded features.
I really like to have a whole DSL instead of some helper methods.

#How to launch it?

* Have ruby 1.9
* Create your own file in bin (see [How to make launch config](https://github.com/Skizzk/Linael/wiki/How-to-make-launch-config))
* Install dependencies
```
bundle install
```
* Launch it! 
```
ruby bin/your_own_linael
```

#How to add my own features?

Read [How to make a new Module](https://github.com/Skizzk/Linael/wiki/How-to-make-a-new-Module)

#How contribute?

  Fork it! Do it! Push it!

#To do
  - [X] How to make a new module
  - [ ] What module should I use and why?
  - [X] Add a way to launch mods by default
  - [X] Config file
  - [ ] Module for wrapping File reading
  - [X] Thread it!
  - [X] Timer
