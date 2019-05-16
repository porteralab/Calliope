function pt = aesdecrypt(ct,key)
% AESCRYPT - decrypt a message using 128-bit AES
%
% USAGE: pt = aescryptpt(ct,key)
%
% ct  = cyphertext, a vector in uint8 form
% key = encryption key, which must be a character string or uint8 vector
% pt  = plaintext, returned in uint8 form
%
% Notes: (1) This function requires Java, which contains the decryption
%            routines.
%        (2) The provided key may have any (nonzero) length. It is hashed
%            to 128 bits using the MD5 hash algorithm.
%        (3) You may convert the recovered plaintext to character form
%            using the CHAR function, e.g., disp(char(pt)).
%        (4) Use this function with the separate DUNZIP routine to enable
%            encryption of several Matlab data types, e.g.
%            M=dunzip(aesdecrypt(ct,key));
%        (5) Carefully tested but no warranty, use at your own risk.
%        (6) Michael Kleder, Nov 2005
%
% EXAMPLE:
%
% M=rand(100);
% key='This is my test encryption key, for trial use.';
% ct=aescrypt(dzip(M),key);
% N=dunzip(aesdecrypt(ct,key));
% all(M(:)==N(:))
%ct= disp(char('ant'));
%key ='this';
if length(ct) ~= length(ct(:))
    error('Cyphertext must have only one non-singleton dimension.')
end
ct=ct(:)';
c = class(ct);
if ~strcmp(c,'uint8')
    error('Cyphertext must be in uint8 form.')
end
c = class(key);
if ~strcmp(c,'uint8') & ~strcmp(c,'char')
    error('Key be in char or uint64 form.')
end
x=java.security.MessageDigest.getInstance('MD5');
x.update(uint8(key(:)));
key=typecast(x.digest,'uint8');
s=javax.crypto.spec.SecretKeySpec(key,'AES');
c=javax.crypto.Cipher.getInstance('AES');
c.init(2,s)
pt = typecast(c.doFinal(ct),'uint8')';
return