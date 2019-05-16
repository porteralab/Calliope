function ct = aescrypt(pt,key)
% AESCRYPT - encrypt a message using 128-bit AES
%
% USAGE: ct = aescrypt(pt,key)
%
% pt  = plaintext, a vector in char or uint8 form
% key = encryption key, which must be a character string or uint8 vector
% ct  = cyphertext
%
% Notes: (1) This function requires Java, which contains the encryption
%            routines.
%        (2) The provided key may have any (nonzero) length. It is hashed
%            to 128 bits using the MD5 hash algorithm.
%        (3) Use this function with the separate DZIP routine to enable
%            encryption of several Matlab data types, e.g.
%            ct=aescrypt(dzip(M),key)
%        (4) Carefully tested but no warranty, use at your own risk.
%        (5) Michael Kleder, Nov 2005
%
% EXAMPLE:
%
% M=rand(100);
% key='This is my test encryption key, for trial use.';
% ct=aescrypt(dzip(M),key);
% N=dunzip(aesdecrypt(ct,key));
% all(M(:)==N(:))

if length(pt) ~= length(pt(:))
    error('Plaintext must have only one non-singleton dimension.')
end
pt=pt(:)';
c = class(pt);
if ~strcmp(c,'uint8') & ~strcmp(c,'char')
    error('Plaintext must be in char or uint8 form.')
end
pt=uint8(pt);
c = class(key);
if ~strcmp(c,'uint8') & ~strcmp(c,'char')
    error('Key be in char or uint8 form.')
end
x=java.security.MessageDigest.getInstance('MD5');
x.update(uint8(key(:)));
key=typecast(x.digest,'uint8');
s=javax.crypto.spec.SecretKeySpec(key,'AES');
c=javax.crypto.Cipher.getInstance('AES');
c.init(1,s)
ct = typecast(c.doFinal(pt),'uint8')';
return