# EasyMSXbas2wav

An simple bas2wav program implemented in bash script. This program gets a MSX basic code file and converts it on a wav file to be loaded directly on an emulator like openmsx or in a real MSX if you are able to put it on a cassette. :D

Can be tested:

```bash
./src/convert.sh ./tests/minimal.bas minimal.wav
./src/convert.sh ./tests/easytr0n.bas easytr0n.wav
```

If you use openMSX you can play execute the wavs by opening it this way:

```
openmsx -machine msx2 -cassetteplayer route_to_wav.wav
```

For example in order to execute minimal.wav:

```
openmsx -machine msx2 -cassetteplayer ./minimal.wav
```

And into the openMSX terminal execute this command:
```
load "cas:",r
```
