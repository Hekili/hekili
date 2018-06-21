## Description

LibArtifactData-1.0 is a data store for addons that need the player's artifacts data. It has a simple API for data access and uses CallbackHandler-1.0 to propagate data changes.

## Why to use

The stock UI provides much of the artifact data only when an artifact is viewed and only for that one artifact. If an addon requires that data prior to the player opening the Artifact UI, or for all artifacts at once, it has to unregister the events the UI uses (so that it doesn't tamper with other UI elements), simulate a shift-right click on the artifact, collect the data and then restore the default state. However this would make the ARTIFACT_UPDATE event fire, upon which all addons listening to it will scan for data anew. This leads to duplicated efforts and possibly some pointless scans, since ARTIFACT_UPDATE does not automatically mean that the data actually changed.

LibArtifactData-1.0 tries to leverage this behavior by keeping the data for all artifacts accessible all the time and informs interested addons about changes when they actually occur.

## Limitations

Data about artifacts placed in the bank is not available until the player opens the bank. LibArtifactData-1.0 can detect such a case and inform addons that some of the data is missing.

Currently LibArtifactData-1.0 does not collect appearance data.

## Feedback

If you have problems using the library, run into any issues or have a feature request, please use the [issue tracker](https://github.com/Rainrider/LibArtifactData-1.0/issues).

## Further reading
  1. [How to use](https://github.com/Rainrider/LibArtifactData-1.0/wiki/How-to-use)  
  2. [API](https://github.com/Rainrider/LibArtifactData-1.0/wiki/API)  
  3. [Events](https://github.com/Rainrider/LibArtifactData-1.0/wiki/Events)  
  4. [Data structure](https://github.com/Rainrider/LibArtifactData-1.0/wiki/Data-structure)  
