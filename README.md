# Humanizer VR Character


## Description
This repository holds an example of how to set up a Humanizer character for VR with IK implemented using the GodotIK addon. It isn't the best organized in its current state since it is stripped
from a separate project I am working on but if there is interest, I will add more documentation. The IK also is not the best, I was still running into trouble with GodotIK when I created this. If anyone can manage
to get a better IK setup running, a pull request would be much appreciated!

## Setup
The following addons are required:
- Godot XR Tools
- Godot Open XR Vendors
- Humanizer 2.2.0+
- Godot IK v1.3.0+ (currently has to be downloaded manually)

To add the custom clothing to the HumanizerConfig, go to the **humanizer_global.tscn** scene in the Humanizer addon, access HumanizerConfig, and add the asset path "res://assets/humanizer" to the Asset Import
Paths.

To get the project running on a VR Headset, follow the following steps:
1. After downloading the addons from the AssetLib, go to Project > ProjectSettings.
2. Ensure the Humanizer and Godot XR Tools plugins are enabled.
3. In the XR section of Project settings, ensure Shaders are enabled and OpenXR is enabled.
4. In the editor, go to Project > Export.
5. Press Add and then Add the android preset.
6. Address the errors that appear when adding the preset.
