#!/bin/sh

docker run -v $(pwd):$(pwd) -w $(pwd) -u $(id -u):$(id -g) ffmpeg_with_eos_eob \
    -i $1 \
    -r 30000/1001 -c:v libx264 -bsf:v h264_mp4toannexb -profile:v main -pix_fmt yuv420p -level:v 4.0 \
    -x264-params "fps=30000/1001:force_cfr=1:slices=1:tff=1:bluray_compat=1:bframes=2:open_gop=0:keyint=15:keyint_min=15:scenecut=-1:bitrate=8000:vbv_maxrate=8000:vbv_bufsize=8000:nal_hrd=cbr:eob=1:eos=1" \
    $2
