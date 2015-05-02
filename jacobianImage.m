function jacobianImage(J, colsize)

for i=1:6
    imJ(:,:,i) = reshape(J(:,i), colsize, colsize);
    imwrite(imJ(:,:,i), sprintf('J%d.png', i));
end