function [ pixelX, pixelY, frames, channel] = parseThorlabsXML(filename)

% PARSETHORLABSXML Parse Thorlabs ThorimageLS XML files.
% 	[pixelX, pixelY, frames, channel] = parseThorlabsXML(filename)
%   Reads Thorlabs ThorimageLS XML files and returns xy resolution (pixelX,
% 	pixelY), frames per Acquisition (frames), and number of channels. TR2011

xmlfile = xmlread(filename);
mainNode = xmlfile.getDocumentElement;
xmlLength = mainNode.getLength;

% to get all nodes and attributes as a list call xmlwrite(filename)
% e.g.: to get the filename as a string call:     
%       NameNode = xmlfile.getElementsByTagName('Name'); Name =
%       NameNode.item(0).getAttribute('name');

LSMNode = xmlfile.getElementsByTagName('LSM');
pixelX = LSMNode.item(0).getAttribute('pixelX');
pixelY = LSMNode.item(0).getAttribute('pixelY');
channel = LSMNode.item(0).getAttribute('channel');

StreamingNode = xmlfile.getElementsByTagName('Streaming');
frames = StreamingNode.item(0).getAttribute('frames');

pixelX = str2num(pixelX);
pixelY = str2num(pixelY);
frames = str2num(frames);
channel = str2num(channel);

end