# xcomposer
A nicer syntax for .XCompose files

## The Compose key

There are two main ways in Linux to type special characters like `λ` and `→`. The first is to use the <kbd>AltGr</kbd> modifier key. For example, in my computer, typing <kbd>AltGr</kbd>+<kbd>S</kbd> results in `§`.

The second way is to use a [Compose Key](https://en.wikipedia.org/wiki/Compose_key). The Compose Key allows you to type a *sequence* of keys to generate a character. For example, in my system you can also type `§` via <kbd>Compose</kbd> <kbd>s</kbd> <kbd>o</kbd>. Compose keys allow you to type many characters that cannot be typed with <kbd>AltGr</kbd> and often involve easier to remember mnemonics.

Note that when using the compose key you type the keys one after the other. When using <kbd>AltGr</kbd> you press the keys at the same time.

## Enabling the Compose key

Keyboards don't typically come with a dedicated <kbd>Compose</kbd> key, so it is likely that you may need to configure your system to remap another key to the <kbd>Compose</kbd>. In my system I remapped the right Windows key to act as <kbd>Compose</kbd>.

The appropriate way to do this remap will depend on the desktop environment you are using. In XFCE this setting can be found under Settings > Keyboard > Layout

## Configuring the Compose key

The default behavior of the Compose key (as well as other "dead-key" combinations such as <kbd>´</kbd>+<kbd>a</kbd>=`á`) is locale-specific and is described in `/usr/share/X11/locale/<mylocale>/Compose`. Most of these Compose files use compose rules from `/usr/share/X11/locale/en_US.UTF-8/Compose` with small modifications.

It is also possible to define custom Compose rules. For example, in my thesis I use the "long right arrow" `⟶`, which can't be easily typed using the default compose rules so I made a special compose sequence for it (<kbd>Compose</kbd> <kbd>-</kbd> <kbd>-</kbd> <kbd>&gt;</kbd> <kbd>space</kbd>). These rules go in a `.XCompose` file in your home folder but they are cumbersome to write, which is where `xcomposer` comes in.

### Making sure your system respects the .XCompose file

The ibus input system that is used by default in many Linux distributions does not respect the customizations present in the `.XCompose` file. You might to use a different input method or revert to the `xim` method. You can do this by setting the following environment variables in your X initialization (`.xsessionrc`)

    export GTK_IM_MODULE="xim"
    export QT_IM_MODULE="xim"

## Installing xcomposer

The easiest way to install xcomposer is via [Luarocks](https://www.luarocks.org)

    luarocks install xcomposer

## Using xcomposer

`xcomposer` takes as input a rule file containing a description of your custom Compose rules and creates a suitable `.XCompose` file for you. You can invoke `xcomposer` as follows:

    xcomposer myrules.xcompose

Passing `-` as the input file will read rules from the standard input

    xcomposer - < myrules.xcompose

By default `xcomposer` writes its output to `$HOME/.XCompose` you can override this with the `-o` flag

    xcomposer myrules.xcompose -o out.txt

You can also use `-o -` to output to standard output.

## The xcomposer rule file

Comments start with `#` and continue until the end of the line.

Each non-blank line describes one compose rule. For example, the following rule makes it possible to write `α` by typing <kbd>Compose</kbd>  <kbd>a</kbd> <kbd>a</kbd>:

    U03B1   α       aa

The contains three fields. The second field is the character that is output by the rule. The first field is the Unicode codepoint number for that character and the third field describes the sequence of keys that need to be pressed after the <kbd>Compose</kbd> key.

The redundancy between the first and second fields is to avoid having the rule output the wrong character due to a typo or copy-paste error. A character-selection application such as `kcharselect` is a good way to find the numeric code for special characters.
 

Use `_` to represent ` ` (space) in rules. For example, the following rule allows us to write `⊢` as <kbd>Compose</kbd> <kbd>|</kbd> <kbd>-</kbd> <kbd>space</kbd>:

    U22A2   ⊢       |-_

To represent a literal underscore use `\_`.

In the current version of `xcomposer` it is impossible to write rules involving whitespace characters other than space (for example, TAB). We may address this limitation in a future version.

## Examples

My personal `xcomposer` rule file can be found in the "examples" folder.
