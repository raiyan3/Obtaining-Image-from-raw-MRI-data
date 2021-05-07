function img_mag = kspc2img_m(k_spc_data, readout_protocol, freq_enc_steps, phase_enc_steps)
% k_spc_2_img_m(k_spc_file, readout_protocol, freq_enc_steps, phase_enc_steps)
% Four input arguments:
% 1) k_spc_data(string/matrix): if string- 'k_spc_data' contain the name of the raw
% data file. The raw data file is expected to be in *.h5 extension this code can be 
% modified in the case{0} of the first switch operation to accept k_space_data in 
% matrix form.
% 2) readout_protocol(string): possible values are 'EPI', 'Radial', 'Cartesian'
% and freq_enc_steps(int), phase_enc_steps(int) obtained from scan parameters
%  
% Date Modified: May 07, 2021
    
    switch ischar(k_spc_data)
        case{1}
            k_spc_mtx = h5read(k_spc_data, sprintf('/signal/channels/%02i',0));
% if the *.h5 file was obtained in JEMRIS, then this file contains a matrix
% of size (3, Nx*Ny), each row contains the signal along x,y and z axis
% respectively.
            k_spc_mtx=k_spc_mtx';
% only the signal along x and y axis is used to construct the image
            k_spc_mag = sqrt(k_spc_mtx(:,1).^2+k_spc_mtx(:,2).^2);
            k_spc_phase = zeros(length(k_spc_mtx(:,1)),1);
            for i=1:numel(k_spc_mtx(:,1))
                x=k_spc_mtx(i,1);
                y=k_spc_mtx(i,2);
                if x>=0 && y>=0
                    phase = atan(y/x);
                elseif x<0 && y>0
                    phase = pi - atan(abs(y/x));
                elseif x<0 && y<0
                    phase = pi + atan(abs(y/x));
                elseif x>0 && y<0
                    phase = -atan(abs(y/x));
                end
            k_spc_phase(i) = phase;
            end
            signal = k_spc_mag.*exp(1i*k_spc_phase);
        case{0}
            %
    end
     raw_data = reshape(signal,phase_enc_steps, freq_enc_steps)';
     
     switch readout_protocol
         case{'EPI'}
            raw_data(2:2:end,:) = fliplr(raw_data(2:2:end,:));
         case{'Radial'}
            % radial readout protocol will be adopted in the future 
         case{'Cartesian'}
            % no additional operation is required
     end
         

     img = fftshift(ifft2(raw_data));
     img_mag = rot90(abs(img),1);
     
     
%      figure(); imagesc(img_mag); colormap('gray'); title('Image');
    