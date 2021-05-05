BEGIN {
    pkt=0;
    time=0;
}
{
if ($1 == "r" && $3 == "3" && $4 == "2") {
    pkt=pkt+$6;
    time=$2;
    printf("%f\t %d\n", time, pkt);
}
}
END {
    #printf("throughput%fMbps", ((pkt/time)*(8/1024)))
}