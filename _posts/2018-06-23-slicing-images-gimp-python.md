---
layout: default
title: "Slicing and Dicing Images with GIMP and Python"
---

# {{ page.title }}

Let's say you have one big image (say, a Telegram sticker) and you need to dice it into a bunch of smaller images (say, Discord emoji).
GIMP can let you do that manually, but frankly so can simpler tools.
GIMP also has powerful scripting support with Python (and also Scheme, but miss me with that) that can let us do that automatically.

## TL;DR how do i do the thing

1. Save your large image somewhere with a useful filename; this script will chuck `_1_1` and `_1_2` etc on the end of the existing filename.
2. Open that image in GIMP.
3. Go to the Filters menu, open Python-Fu, and hit Console.
4. Set up the width and height of your tiles. For 64x64 tiles, for example, type
   ```python
   WIDTH = 64
   HEIGHT = 64
   ```
5. Paste in this big ol' block of code and let it build your tiles and print out the text you can enter in Discord to reconstitute your original image:
   ```python
   from gimpfu import *
   from __future__ import print_function
   import os.path

   def crop(image, x, width, y, height):
       pdb.gimp_image_crop(image, width, height, x, y)
       x_idx = x / width + 1
       y_idx = y / width + 1
       filename = pdb.gimp_image_get_filename(image)
       dir, name = os.path.split(filename)
       root, ext = os.path.splitext(name)
       ext = ".png"
       output_root = root + "_" + str(y_idx) + "_" + str(x_idx)
       output_name = os.path.join(dir, output_root + ext)
       layer = pdb.gimp_image_get_active_layer(image)
       pdb.file_png_save_defaults(image, layer, output_name, output_name)
       print(":" + output_root + ":", end="")
       pdb.gimp_image_delete(image)

   image = gimp.image_list()[0]
   filename = pdb.gimp_image_get_filename(image)

   for y in range(0, 512, WIDTH):
       for x in range(0, 512, HEIGHT):
           crop(pdb.gimp_file_load(filename, filename), x, WIDTH, y, HEIGHT)
       print()

   pass
   ```

There are two minor issues with actually using this code to convert a Telegram sticker into Discord emoji that I'll get to later.

## The Code, Splained

I'll walk through each bit of the code segment above and explain why it's there.

We need the GIMP libraries, the Python 3 `print()` function (because as of GIMP 2.8.22 the GIMP console is still on Python 2), and some path manipulation functions.
```python
from gimpfu import *
from __future__ import print_function
import os.path
```

We're going to crop an image with an X and Y offset and a width and height.
The first step in generating the tile is telling GIMP to do the actual crop.
```python
def crop(image, x, width, y, height):
    pdb.gimp_image_crop(image, width, height, x, y)
```

The next step is to figure out the filename for this specific tile; here we're getting an index back from the offsets and width and height.
```python 
    x_idx = x / width + 1
    y_idx = y / width + 1
    filename = pdb.gimp_image_get_filename(image)
    dir, name = os.path.split(filename)
    root, ext = os.path.splitext(name)
    ext = ".png"
    output_root = root + "_" + str(y_idx) + "_" + str(x_idx)
    output_name = os.path.join(dir, output_root + ext)
```

Once we've got a filename, we can save.
For some reason GIMP's save functions all depend on both the image and the layer, and on two copies of the filename.
```python
    layer = pdb.gimp_image_get_active_layer(image)
    pdb.file_png_save_defaults(image, layer, output_name, output_name)
```

Since the goal is to reconstitute the original image from Discord emoji, we assume that they won't be renamed.
We need the Python 3 print function here to suppress any characters after the string is printed; the Python 2 `print "foo",` trick still emits a space.
```python
    print(":" + output_root + ":", end="")
```

We might as well delete the image from GIMP.
I don't know if this actually serves an important purpose or not.
```python
    pdb.gimp_image_delete(image)
```

We want to grab the original filename.
```python
image = gimp.image_list()[0]
filename = pdb.gimp_image_get_filename(image)
```

Since we defined WIDTH and HEIGHT manually earlier, now we can loop through the image.
I should probably go back in and make it grab the full image width and height, but fuck it, I don't want to.
```python
for y in range(0, 512, WIDTH):
    for x in range(0, 512, HEIGHT):
```

I don't know if GIMP doesn't expose undo in the Python API or if I just couldn't find it, but either way we don't have undo, so we pass in a fresh copy of the image instead.
```python
        crop(pdb.gimp_file_load(filename, filename), x, WIDTH, y, HEIGHT)
```

Since we're building up the emoji text for Discord one row at a time, we need to end the row at the end of a row.
```python
    print()
```

This is just there so the newline after the `for` loop gets pasted successfully.
```python
pass
```

## The Plot Thickens

The first issue with this approach is that Discord (at time of writing, at least) sets a total of 2.25 pixels worth of horizontal margin between emoji, so your reconstituted image will have weird stripes.
It might be feasible to adjust for these in the offsets so that the spacing isn't funky, but honestly that seems like a lot of work.

The second, and more interesting, issue is that Discord has a 50 emoji limit on each server (at least for non-Nitro plebeians; I don't know if that changes if the server owner upgrades).
Slicing a 512x512 image into 32x32 tiles for a full size replica would generate 256 tiles, which might work if you had Discord Nitro and six different dummy servers, but nah.
Slicing into 64x64 tiles that'll be rendered at half size only makes 64 tiles, which works out nicely numerically but is still more than can fit on one server.
Unless we're clever.

I'm not sure how well this generalizes, but for the sticker I'm working with, 16 of those 64 tiles are fully transparent, and therefore identical.
If we could detect this when slicing, we could avoid emitting 15 of those, at which point we come in nicely with 49 tiles, one under the Discord emoji limit.
But how can we detect if an image is fully transparent?

Get histogram info for the alpha channel!
We can use something like this to count how many pixels aren't fully transparent:
```python
_, _, _, _, visible_count, _ = pdb.gimp_histogram(layer, HISTOGRAM_ALPHA, 1, 255)
```

So our final code can detect if each tile is fully transparent before it saves and treat all fully transparent tiles as equivalent to the very first one.

```python
from gimpfu import *
from __future__ import print_function
import os.path

empty_tile_name = None

def crop(image, x, width, y, height):
    global empty_tile_name
    pdb.gimp_image_crop(image, width, height, x, y)
    layer = pdb.gimp_image_get_active_layer(image)
    _, _, _, _, visible_count, _ = pdb.gimp_histogram(layer, HISTOGRAM_ALPHA, 1, 255)
    x_idx = x / width + 1
    y_idx = y / width + 1
    filename = pdb.gimp_image_get_filename(image)
    dir, name = os.path.split(filename)
    root, ext = os.path.splitext(name)
    ext = ".png"
    output_root = root + "_" + str(y_idx) + "_" + str(x_idx)
    output_name = os.path.join(dir, output_root + ext)
    if visible_count > 0 or empty_tile_name is None:
        pdb.file_png_save_defaults(image, layer, output_name, output_name)
    if visible_count == 0:
        if empty_tile_name is None:
            empty_tile_name = output_root
        else:
            output_root = empty_tile_name
    print(":" + output_root + ":", end="")
    pdb.gimp_image_delete(image)

image = gimp.image_list()[0]
filename = pdb.gimp_image_get_filename(image)

for y in range(0, 512, WIDTH):
    for x in range(0, 512, HEIGHT):
        crop(pdb.gimp_file_load(filename, filename), x, WIDTH, y, HEIGHT)
    print()

pass
```

The results are actually fairly impressive, all things considered:

![A halfway decent but slightly stripe-y replica as Discord emoji of the Telegram sticker of Pandora's Fox dabbing.](/assets/2018-06-23-slicing-images-gimp-python-1.png)

(that sticker is by [NL](https://twitter.com/NLDraws) and of [Pandora's Fox](https://twitter.com/pandoras_foxo))

But of course anyone with an ounce of sense would just upload the image so this whole project was a complete waste of three hours.