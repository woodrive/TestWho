package com.winel.test;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class EncryptComm {
	
	/**
	 * @param source string
	 * @return sha1 string
	 * @throws NoSuchAlgorithmException 
	 */
	public static String SHA1Encrypt(String SourceString) throws NoSuchAlgorithmException{
		MessageDigest mDigest = MessageDigest.getInstance("SHA1");
		byte[] result = mDigest.digest(SourceString.getBytes());
		StringBuffer sb = new StringBuffer();
		for(int i = 0; i < result.length; i++){
			sb.append(Integer.toString((result[i] & 0xff) + 0x100, 16).substring(1));
		}
		return sb.toString();
	}

}
