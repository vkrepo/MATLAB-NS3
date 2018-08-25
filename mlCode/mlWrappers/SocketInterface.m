classdef SocketInterface < handle
    % SocketInterface This object is used to send application data packets
    % created in MATLAB to the transmitter's protocol stack in NS-3. It is also
    % used to register callback for getting the application packets from NS-3
    % protocol stack into MATLAB
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    methods (Static)
        function Send(payloadBuf, payloadSize, nodeId, channel, ...
                protocolNum, bssWildcard)
            % Sends the constructed packet from MATLAb to NS3.
            
            mexSocketInterface('SendPacket', payloadBuf, payloadSize, ...
                nodeId, channel, protocolNum, bssWildcard);
        end
        
        function RegisterRXCallback(netDevContainer, callback)
            % Registers the MATLAB RX packet callback for the given net device.
            
            mexSocketInterface('ReceivePacket', netDevContainer.get(), ...
                func2str(callback));
        end
    end
end
