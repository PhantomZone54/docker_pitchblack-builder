<div align="center">
  
  <h1><i>Pitchblack Builder</i></h1>
  
  [![Actions Status](https://github.com/PhantomZone54/docker_pitchblack-builder/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/PhantomZone54/docker_pitchblack-builder/actions)
  [![](https://images.microbadger.com/badges/image/fr3akyphantom/pitchblack-builder2.svg)](https://microbadger.com/images/fr3akyphantom/pitchblack-builder2 "Get your own image badge on microbadger.com")
  [![](https://images.microbadger.com/badges/version/fr3akyphantom/pitchblack-builder2.svg)](https://microbadger.com/images/fr3akyphantom/pitchblack-builder2 "Get your own version badge on microbadger.com")
  [![](https://images.microbadger.com/badges/commit/fr3akyphantom/pitchblack-builder2.svg)](https://microbadger.com/images/fr3akyphantom/pitchblack-builder2 "Get your own commit badge on microbadger.com")
  [![Docker Pulls](https://img.shields.io/docker/pulls/fr3akyphantom/pitchblack-builder2)](https://hub.docker.com/r/fr3akyphantom/pitchblack-builder2 "Show the Docker Repository")
  
  <h3><i>Container based upon Ubuntu Bionic 18.04 LTS for building PitchBlack Recovery Projects</i></h3>
  
</div>

---

#### This Image was Rebased From [@yshalsager/cyanogenmod:latest](https://hub.docker.com/r/yshalsager/cyanogenmod "Show the Docker Repository") which is a popular Docker Container used for Building Android ROMs, specially CyanogenMod13.

### Get the Image

```bash
# pull the latest image by running the following command
docker pull fr3akyphantom/pitchblack-builder2:latest
```

### Run the Container

```bash
docker run --privileged --rm -it \
  --name docker_pitchblack-builder2 --hostname pitchblack-builder2 \
  -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) \
  # mount working directory as volume
  -v "$HOME:/home/builder:rw,z" \
  # mount ccache volume too, host machine should have ccache installed for this
  -v "$HOME/.ccache:/srv/ccache" \
  fr3akyphantom/pitchblack-builder2:latest \
  /bin/bash
```
:reminder_ribbon: Remember, `/home/builder/pitchblack/` (as of container's `$HOME/pitchblack/`) is the default working directory for the container. So, navigate to __$HOME/pitchblack__ in host machine and then pull the Docker Image.

### Start the Build

When this Image runs as the pitchblack-builder Container, You won't need to install any other softwares.
This has inbuilt openjdk8, adb+fastboot, wget, curl, git, automake+cmake+clang, build-essential, python, and all the reqired dependencies.

_repo_ is installed, _ghr_ is also installed for Manual Github Releases.
_sshpass_ & _wput_ is installed for FTP & SourceForge uploading support.

So, you can start the build from where you ran the `docker run` command earlier.

```bash
# change directory to match the working directory -> /home/builder/pitchblack/
cd /home/builder/pitchblack/ || cd $HOME/pitchblack/
# set your github usename and email, required by repo binary
git config --global user.email $GitHubMail
git config --global user.name $GitHubName
git config --global color.ui true
# set your ENVs now, if you want to
# now the main work begins...
# initialize the repo, pick the _MANIFEST_BRANCH_ & set the depth too
repo init --depth 1 -q -u https://github.com/PitchBlackRecoveryProject/manifest_pb.git -b ${MANIFEST_BRANCH}
# sync the repo with maximum connections, use _j32_ / _j24_ / _j16_
# wait for the whole repo to be downloaded
time repo sync -c -f -q --force-sync --no-clone-bundle --no-tags -j32
# clone the specific device tree
git clone https://github.com/PitchBlackRecoveryProject/${PROJECT_REPONAME} device/${VENDOR}/${CODENAME}
# repo sync again, only if your device has dependencies
time repo sync -c -f -q --force-sync --no-clone-bundle --no-tags -j32
# you can now delete the _.repo_ folder if you need space
# but make sure you keep the _.repo/manifests_ folder intact
# if you want to change some repo branches, do it now
rm -rf bootable/recovery && git clone https://github.com/PitchBlackRecoveryProject/android_bootable_recovery -b ${PBRP_BRANCH} bootable/recovery
rm -rf vendor/pb && git clone https://github.com/PitchBlackRecoveryProject/vendor_pb -b pb vendor/pb
# Start the Build Process
export ALLOW_MISSING_DEPENDENCIES=true
source build/envsetup.sh
lunch ${BUILD_LUNCH}
make -j16 recoveryimage
```

### Well, there you have it! I'll just stop now :hand: 

#### You know the rest processes. Enoy Building... :stuck_out_tongue_winking_eye: 
