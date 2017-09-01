function score = palmcode_diff(im1, im2)
%take two palmcode as input and output the difference of their histogram

    siz1 = size(im1);
    siz2 = size(im2);
    if ~all(siz1 == siz2)
        disp('error: image size should be the same!')
        score = [];
        return
    end
    
    bsize = 8;
    blocks = 1:bsize:siz1(1)+1;
    
    notfit = mod(siz1(1), 8);
    if notfit
        blocks = [blocks, siz1(1)];
    end
    
    histo_vector1 = code_image_histo(im1, blocks);
    histo_vector2 = code_image_histo(im2, blocks);
    
    num_of_blocks = numel(blocks) - 1;
    num_of_blocks = num_of_blocks*num_of_blocks;
    
    score = sum(abs(histo_vector1 - histo_vector2)) / num_of_blocks;
end

function histo_vector = code_image_histo(im, range)
   histo_vector = [];   
   len = numel(range) - 1;
   
   for m=1:len
       for n=len
           block = im(range(m):range(m+1)-1, range(n):range(n+1)-1);
           histo_vector = [histo_vector, code_block_histo(block)];
       end       
   end
end

function hv = code_block_histo(im)
   hv = zeros(1, 9);
   [row, col] = size(im);
   
   for t=1:row
       for k=1:col
           idx = (im(t,k)/20) + 1;
           hv(idx) =  hv(idx) + 1;
       end
   end
   
   hv = hv / sum(hv);
end