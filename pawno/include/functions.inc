stock Float:getdist(Float:x1,Float:y1,Float:x2,Float:y2)
{
    return floatsqroot( floatpower((x1 < x2) ? (x1 - x2): (x2 - x1),2.0) + floatpower((y1 < y2) ? (y1 - y2) : (y2 - y1),2.0) ) ;
}

stock Float:getdist3d(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
	return floatsqroot(floatpower((z1<z2) ? (z1-z2) : (z2-z1), 2.0) + floatpower(getdist(x1, y1, x2, y2), 2.0));
}

