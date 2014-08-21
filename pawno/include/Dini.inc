/*
 *            Dini 1.6
 *       (c) Copyright 2006-2008 by DracoBlue
 *
 * @author    : DracoBlue (http://dracoblue.com)
 * @date      : 13th May 2006
 * @update    : 16th Sep 2008
 *
 * This file is provided as is (no warranties).
 *
 * It's released under the terms of MIT.
 *
 * Feel free to use it, a little message in
 * about box is honouring thing, isn't it?
 *
 */

#if defined _dini_included
  #endinput
#endif

#define _dini_included
#pragma library dini

#if defined MAX_STRING
#define DINI_MAX_STRING MAX_STRING
#else
#define DINI_MAX_STRING 255
#endif

stock dini_Exists(filename[]) {
	return fexist(filename);
}

stock dini_Remove(filename[]) {
	return fremove(filename);
}

stock dini_Create(filename[]) {
	if (fexist(filename)) return false;
	new File:fhnd;
	fhnd=fopen(filename,io_write);
	if (fhnd) {
		fclose(fhnd);
		return true;
	}
	return false;
}

stock dini_Set(filename[],key[],value[]) {
	// If we have no key, it can't be set
	// we also have no chance to set the value, if all together is bigger then the max string
	new key_length = strlen(key);
	new value_length = strlen(value);
	if (key_length==0 || key_length+value_length+2>DINI_MAX_STRING) return false;
	
	new File:fohnd, File:fwhnd;
	new tmpres[DINI_MAX_STRING];
	new bool:wasset=false;
	
	// Let's remove the old *.part file if there was one.
	format(tmpres,sizeof(tmpres),"%s.part",filename);
	fremove(tmpres);
	
	// We'll open the source file.
	fohnd=fopen(filename,io_read);
	if (!fohnd) return false;
	
	fwhnd=fopen(tmpres,io_write);
	if (!fwhnd) {
		// we can't open the second file for writing, so .. let's close the open one and exit.
		fclose(fohnd);
		return false;
	}
	
	while (fread(fohnd,tmpres)) {
		if (
			!wasset
			&& tmpres[key_length]=='='
			&& !strcmp(tmpres, key, true, key_length)	
		) {
				// We've got what needs to be replaced!
				format(tmpres,sizeof(tmpres),"%s=%s",key,value);
				wasset=true;
		} else {
			DINI_StripNewLine(tmpres);
		}
		fwrite(fwhnd,tmpres);
		fwrite(fwhnd,"\r\n");
	}

	if (!wasset) {
		format(tmpres,sizeof(tmpres),"%s=%s",key,value);
		fwrite(fwhnd,tmpres);
		fwrite(fwhnd,"\r\n");
	}

	fclose(fohnd);
	fclose(fwhnd);

	format(tmpres,sizeof(tmpres),"%s.part",filename);
	if (DINI_fcopytextfile(tmpres,filename)) {
		return fremove(tmpres);
	}
	return false;
}


stock dini_IntSet(filename[],key[],value) {
   new valuestring[DINI_MAX_STRING];
   format(valuestring,DINI_MAX_STRING,"%d",value);
   return dini_Set(filename,key,valuestring);
}

stock dini_Int(filename[],key[]) {
   return strval(dini_Get(filename,key));
}

stock dini_FloatSet(filename[],key[],Float:value) {
   new valuestring[DINI_MAX_STRING];
   format(valuestring,DINI_MAX_STRING,"%f",value);
   return dini_Set(filename,key,valuestring);
}

stock Float:dini_Float(filename[],key[]) {
   return floatstr(dini_Get(filename,key));
}

stock dini_Bool(filename[],key[]) {
   return strval(dini_Get(filename,key));
}

stock dini_BoolSet(filename[],key[],value) {
	if (value) {
		return dini_Set(filename,key,"1");
	}
	return dini_Set(filename,key,"0");
}

stock dini_Unset(filename[],key[]) {
	// If we have no key, it can't be set
	// we also have no chance to unset the key, if all together is bigger then the max string
	new key_length = strlen(key);
	if (key_length==0 || key_length+2>DINI_MAX_STRING) return false;
	
	new File:fohnd, File:fwhnd;
	new tmpres[DINI_MAX_STRING];
	
	// Let's remove the old *.part file if there was one.
	format(tmpres,DINI_MAX_STRING,"%s.part",filename);
	fremove(tmpres);
	
	// We'll open the source file.
	fohnd=fopen(filename,io_read);
	if (!fohnd) return false;
	
	fwhnd=fopen(tmpres,io_write);
	if (!fwhnd) {
		// we can't open the second file for writing, so .. let's close the open one and exit.
		fclose(fohnd);
		return false;
	}
	
	while (fread(fohnd,tmpres)) {
		if (
			tmpres[key_length]=='='
			&& !strcmp(tmpres, key, true, key_length)	
		) {
				// We've got what needs to be removed!
		} else {
			DINI_StripNewLine(tmpres);
			fwrite(fwhnd,tmpres);
			fwrite(fwhnd,"\r\n");
		}
	}
	
	fclose(fohnd);
	fclose(fwhnd);

	format(tmpres,DINI_MAX_STRING,"%s.part",filename);
	if (DINI_fcopytextfile(tmpres,filename)) {
		return fremove(tmpres);
	}
	return false;
}

stock dini_Get(filename[],key[]) {
	new tmpres[DINI_MAX_STRING];
	
	new key_length = strlen(key);
	if (key_length==0 || key_length+2>DINI_MAX_STRING) return tmpres;
	
	new File:fohnd;
	fohnd=fopen(filename,io_read);
	if (!fohnd) return tmpres;
	
	while (fread(fohnd,tmpres)) {
		if (
			tmpres[key_length]=='='
			&& !strcmp(tmpres, key, true, key_length)	
		) {
			/* We've got what we need */
			DINI_StripNewLine(tmpres);
			strmid(tmpres, tmpres, key_length + 1, strlen(tmpres), DINI_MAX_STRING);
			fclose(fohnd);
			return tmpres;
		}
	}
	fclose(fohnd);
	return tmpres;
}


stock dini_Isset(filename[],key[]) {
	new key_length = strlen(key);
	if (key_length==0 || key_length+2>DINI_MAX_STRING) return false;
	
	new File:fohnd;
	fohnd=fopen(filename,io_read);
	if (!fohnd) return false;
	
	new tmpres[DINI_MAX_STRING];
	while (fread(fohnd,tmpres)) {
		if (
				tmpres[key_length]=='='
			&&  !strcmp(tmpres, key, true, key_length)	
		) {
			// We've got what we need
			fclose(fohnd);
			return true;
		}
	}
	fclose(fohnd);
	return false;
}



stock DINI_StripNewLine(string[]) {
	new len = strlen(string);
	if (string[0]==0) return ;
	if ((string[len - 1] == '\n') || (string[len - 1] == '\r')) {
		string[len - 1] = 0;
		if (string[0]==0) return ;
		if ((string[len - 2] == '\n') || (string[len - 2] == '\r')) string[len - 2] = 0;
	}
}

stock DINI_fcopytextfile(oldname[],newname[]) {
	new File:ohnd,File:nhnd;
	if (!fexist(oldname)) return false;
	ohnd=fopen(oldname,io_read);
	if (!ohnd) return false;
	nhnd=fopen(newname,io_write);
	if (!nhnd) {
		fclose(ohnd);
		return false;
	}
	new tmpres[DINI_MAX_STRING];
	while (fread(ohnd,tmpres)) {
		DINI_StripNewLine(tmpres);
		format(tmpres,sizeof(tmpres),"%s\r\n",tmpres);
		fwrite(nhnd,tmpres);
	}
	fclose(ohnd);
	fclose(nhnd);
	return true;
}