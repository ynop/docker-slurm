#docker run -d --net="host" --name slurm -v /grid:/home srv-fs-t-610.zhaw.ch:5555/slurmctl

# Linux
docker run -d -p 6817:6817 -p 6818:6818 -p 57000-59999:57000-59999 --name slurm -v /grid:/home ynop/slurmctl

# OSX
docker run -d -p 6817:6817 -p 6818:6818 -p 57000-59999:57000-59999 --privileged=true --name slurm ynop/slurmd