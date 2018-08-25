classdef utils
    % This class is collection of some utility functions used frequently
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties
    end
    methods(Static)
        
        % Pack the MATLAB structure info into packet according to size of
        % fields in the structure.
        function [packedPayload, payloadSize] = packStruct(payload)
            pktFields = fieldnames(payload); % Reading all fields
            numFields = size(pktFields,1); % Reading number of fields
            i=1;
            pktIndex=1;
            while(i<=numFields)
                fieldName = char(pktFields(i));
                fieldVal = payload.(char(fieldName));
                fieldInt8 = typecast(fieldVal, 'uint8');
                memObj = whos('fieldVal');
                sizeInBytes = memObj.bytes;
                packedPayload(pktIndex: (pktIndex+sizeInBytes-1)) = fieldInt8;
                pktIndex = pktIndex + sizeInBytes;
                i= i+1;
            end
            payloadSize = pktIndex-1;            
        end
        
        
        function t = dec2twos(x, nbits)
            %error(nargchk(1, 2, nargin));
            x = x(:);
            maxx = max(abs(x));
            nbits_min = nextpow2(maxx + (any(x == maxx))) + 1;
            
            % Default number of bits.
            if nargin == 1 || isempty(nbits)
                nbits = nbits_min;
            elseif nbits < nbits_min
                nbits = nbits_min;
            end
            
            t = repmat('0', numel(x), nbits); % Initialize output:  Case for x = 0
            if any(x > 0)
                t(x > 0, :) = dec2bin(x(x > 0), nbits);           % Case for x > 0
            end
            if any(x < 0)
                t(x < 0, :) = dec2bin(2^nbits + x(x < 0), nbits); % Case for x < 0
            end
        end
        
        
        function x = twos2dec(t)
            if iscellstr(t)
                t = char(t);
            end
            
            % Convert to numbers.
            x = bin2dec(t);
            
            % Get the number of bits as the number of 0's and 1's in each row.
            nbits = sum(t == '0' | t == '1', 2);
            
            % Case for negative numbers.
            xneg = log2(x) >= nbits - 1;
            % xneg = bitshift(x, -(nbits - 1)) == 1;
            if any(xneg)
                x(xneg) = -( bitcmp(x(xneg), nbits(xneg)) + 1 );
            end
        end
    end
end
 
