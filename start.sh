#docker run -d --net="host" --name slurm -v /grid:/home srv-fs-t-610.zhaw.ch:5555/slurmctl
docker run -d --net="host" --name slurm -v /grid:/home ynop/slurmctl