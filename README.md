# hybrid-decen-mplayer
Very crude concept of a hybrid between decentralized network and centralized server. 

## Prereqisites
* Linux VPS with HTTP server running
* Linux desktop with `jq` and `mpv`
* web3.storage account and token

## Programs 
* `mdjsoner.sh <output>.json`: Generate music index file. Put this in the VPS. use MDJS_PREFIX env to automatically append IP address of your VPS or local directory for local testing. Has to be.json.
* `uploader.js --token=(yourtoken) <indexfile>.json`: upload .json music index file to web3.storage. Needs token, enter it using --token=(your token) argument. Outputs link that directs to the IPFS address of the uploaded .json index file.
*`ipmd.sh <link>`: Prints index, choose track, then calls `mpv` to play said track. Needs `jq` to parse the index .json.

