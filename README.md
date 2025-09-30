# How to Setup Properly
- you must atleast have git installed
- then run:
```
git clone https://github.com/lua-gods/GNs-Avatar-4 --recurse-submodules
```
but if you already git cloned and and came back crawling here for not reading this lmao, run these:
```
git submodule init 
git submodule update
```

# Layout
|Path|Purpose|
|--|--|
|core|also gets automatically executed, but it has priority over **auto**|
|auto|scripts that automatically get executed on initialization, its where all my generic scripts are|
|lib|where my libraries are, or the scripts that you might have known are located at|
|textures|its.. where my textures are at|
|.folder|these are files that figura never touches, they serve as my archive|