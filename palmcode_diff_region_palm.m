function score = palmcode_diff_region_palm(im1, im2, bw_im1, bw_im2)
%take two palmcode as input and output the difference of their histogram

    siz1 = size(im1);
    siz2 = size(im2);
    if ~all(siz1 == siz2)
        disp('error: image size should be the same!')
        score = [];
        return
    end
    
    %score relative to im1
    histo_vector1 = code_image_histo(im1, bw_im1);
    histo_vector2 = code_image_histo(im2, bw_im1);
    score1 = sum(abs(histo_vector1 - histo_vector2)) / sum(histo_vector1);
    
    %score relative to im2
    histo_vector1 = code_image_histo(im1, bw_im2);
    histo_vector2 = code_image_histo(im2, bw_im2);
    score2 = sum(abs(histo_vector1 - histo_vector2)) / sum(histo_vector1);
    
    if score1 < score2
       score = score1;
    else
       score = score2;
    end
end

function histo_vector = code_image_histo(im, im_witness)
   [limx, limy] = size(im);
   row = 1;
   histo_vector = [];
   bsize = 31;
   args = bsize+1;
   
   
   while (limx >= row+bsize)
       col = 1;
       while (limy >= col+bsize)
            block = im(row:row+bsize, col:col+bsize);
            
            temp = im_witness(row:row+bsize, col:col+bsize);
            if ~any(temp(:))
                col = col+bsize+1;
                continue
            end
            
            histo_vector = [histo_vector, code_block_histo(block, args, args)];
            col = col+bsize+1;
       end
       
       row = row+bsize+1;
   end
end

function hv = code_block_histo(im, row, col)
   hv = zeros(1, 9);
   
   for t=1:row
       for k=1:col
           idx = (im(t,k)/20) + 1;
           hv(idx) =  hv(idx) + 1;
       end
   end
end