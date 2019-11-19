function R= traceRatio1(Sb,Sh,reducedDimension,ite)
% compute the traceRatio problem,using Algorithm 1 in jinx paper.
% -Sb: input matrix, it is a square matrix
% -Sh: input matrix, it is a square matrix
% -reducedDimension: the dimension of the data after dimension reduction
% -ite: the max iteration number

% -R: the output matrix,contains reducedDimension columns

tmp=size(Sb);
rowNum=tmp(1); % row number of matrix R
R=eye(rowNum);
R=R(:,1:reducedDimension);


for i=1:ite %�������R
    oldR=R;
    

    lambda=trace(R'*Sb*R)/trace(R'*Sh*R); % line 3 in Algorithm 1
    tmp=Sb-lambda*Sh;
    [tmpv,tmpd]=eig(tmp);
    
%     tmpv=real(tmpv);
%     tmpd=real(tmpd);
    
    tmp=sum(tmpd);
    [tmp, tmpi]=sort(tmp,2, 'descend');% ���н�������
    tmpv=tmpv(:,tmpi);
    R=tmpv(:,1:reducedDimension);
    
    %---------------------------------------------------------------------
    % Reshape the projection matrix for the sake of orthogonal transformation invariance
    % line 6 and after
    
    %|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
     % ���ַ�������һ�֣�ԭʼ����
      tmp=R*R'*Sh*R*R';
    %|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||    
         % ���ַ������ڶ��֣� ��Sh����һ���Ƚϴ��������ֹ̫С�������̫�󣬲���֤�ǶԳƵġ�
     
         
%      myscale=size(R,1);
%      myR=R.*myscale;
%      tmp=myR*(myR')*Sh*myR*(myR');
%      tmp=(tmp+tmp')./2;
%      tmp=tmp./(myscale^4);
    %|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   
    
    [tmpv,tmpd]=eig(tmp);
    
%     tmpv=real(tmpv);
%     tmpd=real(tmpd);
    
%     if sum(sum(abs(tmp-tmpv*tmpd*tmpv')))/rowNum/rowNum>0.00001
%         disp('svd error');
%     end
    tmp=sum(tmpd);
    [tmp, tmpi]=sort(tmp,2, 'descend');% ������������
    tmpv=tmpv(:,tmpi);
    R=tmpv(:,1:reducedDimension);
    
    
%     if sum(sum(abs(oldR-R)))<rowNum*reducedDimension*0.001
%         break;
%     end



end
