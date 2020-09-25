# mechanical-pencil
A generative art system built in Processing (with Hype Framework).
![Examples](exampleImages.png)

## Getting Started

### Requirements

1. [Processing 3](https://processing.org)
2. [Hype Framework](https://www.hypeframework.com)
3. [controlP5](http://www.sojamo.de/libraries/controlP5/)

### Installing
Install Hype and ControlP5 via the Contribution Manager in Processing:
In the Processing IDE, choose `Sketch > Import Library... > Add Library...`

Alternately, download the current version from the respective site and add the library files to the `libraries` folder inside the folder indicated for `Sketchbook Location` in the Processing preferences.

### Setup

To run the app, you need at least one PNG image in your project, and a config file that indicates how to process that image in the sketch. 

#### Config 
The `build.pde` sketch loads configuration data from the `data/config.json` file.  
This is the minimum required info in the config file:
```
{
  "layers": [
    {
      "imageNames": [
        "darkJellies/jellyfish3.png"
      ],
      "imagePoolSize": 5,
    },
  ]
}
```

Your config will list an array of one or more Layer objects for which you must specify the `imageNames` array, and the `imagePoolSize` count.

There are many more configuration options available. See the [included config file](build/data/config/config.json) as an example or see the [Config Options](#config-options) section for details.

#### Images
Project images should be placed in the `data/images` folder. Subfolders are ok.
Transparent PNGs will work best.

## Usage
The app works by randomly placing copies of your image onto the canvas. The parameters defined in your configuration dictate the rules for placement and randomization.

Compositions can be saved from the app as print-quality images, or as smaller previews with associated data files. 

### Key Commands

**`1`-`9`**: Reposition images for the associated layer. Images are cumulative, so each key press adds more images to the composition. The number defined for `imagePoolSize` dictates how many images will appear for each key press.   

Hold **`Shift`** while pressing the layer number to re-stamp the images in the same locations. This can emphasize a certain placement of images if the `imageAlpha` is less than 100%.  

**`X`**: Clear the canvas.

**`S`**: Save a preview image with associated data to the `output` folder.  

**`SHIFT + S`**: Save a print-resolution image with associated data to the `output` folder.  

**`C`**: Save the data file only (without image).  

**`L`**: Load settings from a config or image data file.  

**`SHIFT + L`**: Reconstitute a composition from a data file.  

**`R`**: Reload data.  

**`D`**: Reconstitute a composition from a data file **at double the original resolution**. 

**`SHIFT + R`**: Start the [Render Queue](#render-queue).

**`E`**: Toggle the settings editor.  

**`M`**: Toggle the Key Commands Menu.

### Render Queue
Saving large, complex compositions at print-resolution can sometimes be slow. My preferred workflow is to save smaller preview images (`s` key) while I'm working and reconstitute them from the data files later to export the full size images.

To automate this process, place the data files for your images in the `data/renderQueue` folder, run the sketch and press `SHIFT + R` to sequentially process the files, saving a print-resolution image for each data file.


## Config Options

### Project Settings
**`printResolution`** (integer)  
The resolution to use for your hi-res image exports.

**`printHeightInches`** (number)  
The height of your hi-res image in inches.

**`printWidthInches`** (number)  
The width of your hi-res image in inches.

**`layers`** (array)  
An array of objects which describe settings for each layer in your sketch.

### Layer Settings
WIP...


## License

This project is licensed under the Unlicense - see the [LICENSE.md](LICENSE.md) file for details.
