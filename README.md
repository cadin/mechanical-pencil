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

There are many more configuration options available. See the [included config file](build/data/config.json) as an example or see the [Config Options](#config-options) section for details.

#### Images
Project images should be placed in the `data/images` folder. Subfolders are ok.
Transparent PNGs will work best.

## Usage
### Key Commands

### Render Queue



## Config Options


## License

This project is licensed under the Unlicense - see the [LICENSE.md](LICENSE.md) file for details.
