function Temp_Text(datafiles,labelfiles,afa)
%datafiles = ['domain_1_7_I.txt';'domain_4_8_I.txt';'domain_5_9_I.txt';'domain_2_6_I.txt'];
%labelfiles = ['label_1_7_I.txt';'label_4_8_I.txt';'label_5_9_I.txt';'label_2_6_I.txt'];
global TrainX;
global TrainY;
global TrainXY;
global TestX;
global TestY;
global size_sets;

global gama;
gama = 145;
%data_file = datafiles;
%label_file = labelfiles;

data_file = datafiles;
label_file= labelfiles;

ndomain = size(data_file,1);


%%%------------���ϲ����ǲ���������ϣ����ұ�����Combs��-------------------------%%%
global index1; %��¼���������Ĵ���

%---------������Ҫ��ӡ����ȫ�ֱ���-------------------%
global AL; %��¼����domain��������Խ��׼ȷ��
global AT; %��¼����domain�Բ��Լ����Ե�׼ȷ��
global AT0;
global Ensemble0; %��¼�Ż�ǰ����domain���в��ԣ�Ȼ��Ensemble�Ľ��
global Ensemble; %��¼����domain���в��ԣ�Ȼ��Ensemble�Ľ��
global Time_initial; %��¼�õ���ʼֵ��ʱ��
global Time_3;  %��¼�ܵ�����ʱ��
AL = zeros(1,ndomain-1); %��ŶԱ�����Ե�׼ȷ��
AT = zeros(1,ndomain-1); %��ŶԲ��Լ����Ե�׼ȷ��
AT0 = zeros(1,ndomain-1); %���δ�Ż�ǰ�Բ��Լ���׼ȷ��
totalA = 0;
%-------------------------------------------------------------%
index1 = 0; %Inilization
%-------------------------------------------------------------%

%//////////////////////////////////////////////////
fid = fopen('outputlatex.dat','w');

Ensemble = 0;
Time_3 = 0;
StrText = strcat('\begin{table} ','\centering');
fprintf(fid,'%s\n',StrText);
StrText = strcat('\caption{XXXXXXXXX}\label{tb_ss}',' \begin{scriptsize}');
fprintf(fid,'%s\n',StrText);
StrText = strcat('\begin{tabular}{@{}c c c c c c c c c c c c c c c@{}}',' \hline');
fprintf(fid,'%s\n',StrText);
StrText = strcat('\multirow{2}{*}{$\alpha$} & \multicolumn{2}{c}{Domain1} & & \multicolumn{2}{c}{Domain2}& & \multicolumn{2}{c}{Domain3} & \multirow{2}{*}{Ensemble(\%)} & \multirow{2}{*}{Time(s)}\\');
fprintf(fid,'%s\n',StrText);
StrText = strcat('\cline{2-3} \cline{5-6} \cline{8-9}',' &  AL$_{1}${(\%)} & AT$_{1}${(\%)} & &  AL$_{2}${(\%)} & AT$_{2}${(\%)} & & AL$_{3}${(\%)} & AT$_{3}${(\%)} & & ');
fprintf(fid,'%s\n',StrText);

size_sets = zeros(ndomain,2); %�洢ÿ��domain����������������������ÿһ�е�һ���������������ڶ�����Ϊ������������ndomain��
TrainX = [];
TrainY = [];
TrainXY = [];
for j=1:(ndomain-1)
    A = load(data_file(j,:));
    A = spconvert(A);
    B = textread(label_file(j,:));
    size_sets(j,1) = size(A,1);
    size_sets(j,2) = size(A,2);
    tmpnum_1 = 0;
    if j>1
        for h=1:(j-1)
            tmpnum_1 = tmpnum_1+size_sets(h,2);
        end
    end
    TrainX = [TrainX,A];
    TrainY = [TrainY,B];
    TrainXY = [TrainXY,scale_cols(A,B)];
    %TrainX(:,(tmpnum_1+1):(tmpnum_1+size(A,2))) = A;
    %TrainY(1,(tmpnum_1+1):(tmpnum_1+size(B,2))) = B;
    %TrainXY(:,(tmpnum_1+1):(tmpnum_1+size(A,2))) = scale_cols(A,B);
end
A = load(data_file(ndomain,:));
A = spconvert(A);
B = textread(label_file(ndomain,:));
size_sets(ndomain,1) = size(A,1);
size_sets(ndomain,2) = size(A,2);
TestX = A;
TestY = B;
clear A;
clear B;
fprintf('.....................................\n');
%TrainXY = scale_cols(TrainX,TrainY);
fprintf('...................finish...........\n');
tstart = cputime;
W0 = mul_predict_luop(TrainXY,size_sets);
tend = cputime;
Time_initial = tend - tstart;
for i=1:ndomain-1
    tmp_1 = 0;
    if i>1
        for j=1:(i-1)
            tmp_1 = tmp_1+size_sets(j,2);
        end
    end
    tempTrainX = TrainX(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    tempTrainY = TrainY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
    tmp_2 = 0;
    if i>1
        for j=1:(i-1)
            tmp_2 = tmp_2+size_sets(j,1);
        end
    end
    w1 = W0((tmp_2+1):(tmp_2+size_sets(i,1)),1);
    s1 = w1'*tempTrainX;
    p1 = 1./(1 + exp(-s1));
    AL(1,i) = getResult(p1,tempTrainY);
end
%         fprintf('close test:Respective result is one:%g   two:%g  three:%g\n',AL(1,1),AL(1,2),AL(1,3));
fprintf('.....................................\n');

w00 = zeros(size(TrainX,1),1);
lambda = exp(linspace(-0.5,6,20));
f1max = -inf;
for i = 1:length(lambda)
    w_0 = train_cg(TrainXY,w00,lambda(i));
    f1 = logProb(TrainXY,w_0);
    if f1 > f1max
        f1max = f1;
        wbest = w_0;
    end
end
ptemp = 1./(1 + exp(-wbest'*TestX));
totalA = getResult(ptemp,TestY);
fprintf('total result:%g\n',totalA);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
afas = 0:0.05:0.25;
for afasindex=1:length(afas)
    afa = afas(afasindex);
    tstart = cputime;

    %[W,result] = quickDown(W0,afa,0.1);
    [W,result] = PRP_CG(W0,afa,size_sets,0.1); %size_sets��¼����domain�Ĵ�С
    %[W,result] = FR_CG(W0,afa,0.1);
    tend = cputime;
    Time_3 = tend - tstart + Time_initial; %�����ܵ�����ʱ��

    if afasindex == 1
        StrText = ('\\\hline');
        fprintf(fid,'%s\n',StrText);
        StrText = strcat(num2str(0),' &');
        for dd = 1:(ndomain-1)
            StrText = strcat(StrText,num2str(AL(dd)*100),' & ',num2str(AT0(dd)*100));
            if dd < (ndomain-1)
                StrText = strcat(StrText,' & & ');
            else
                StrText = strcat(StrText,' & ');
            end
        end
        StrText = strcat(StrText,num2str(Ensemble0*100),' & ',num2str(Time_initial));
        fprintf(fid,'%s\n',StrText);
    end
    
    StrText = ('\\\hline');
    fprintf(fid,'%s\n',StrText);


    for i=1:ndomain-1
        tmp_1 = 0;
        if i>1
            for j=1:(i-1)
                tmp_1 = tmp_1+size_sets(j,2);
            end
        end
        tempTrainX = TrainX(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
        tempTrainY = TrainY(:,(tmp_1+1):(tmp_1+size_sets(i,2)));
        tmp_2 = 0;
        if i>1
            for j=1:(i-1)
                tmp_2 = tmp_2+size_sets(j,1);
            end
        end
        w1 = W((tmp_2+1):(tmp_2+size_sets(i,1)),1);
        s1 = w1'*tempTrainX;
        p1 = 1./(1 + exp(-s1));
        AL(1,i) = getResult(p1,tempTrainY);%��¼Ϊ�Ż���Ա����Ԥ��׼ȷ��
    end

    %             fprintf('close test:Respective result is one:%g   two:%g  three:%g\n',AL(1,1),AL(1,2),AL(1,3));
    StrText = strcat(num2str(afa),' &');
    for dd = 1:(ndomain-1)
        StrText = strcat(StrText,num2str(AL(dd)*100),' & ',num2str(AT(dd)*100));
        if dd < (ndomain-1)
            StrText = strcat(StrText,' & & ');
        else
            StrText = strcat(StrText,' & ');
        end
    end
    StrText = strcat(StrText,num2str(Ensemble*100),' & ',num2str(Time_3));

    fprintf(fid,'%s\n',StrText);

end

StrText = strcat('\\\hline ','\end{tabular} ','\\ The accuracy of total samples-sets:' ,num2str(totalA));

StrText = strcat(StrText,' \end{scriptsize} ','\end{table} ');
fprintf(fid,'%s\n\n',StrText);

fclose(fid);

clear TrainX;
clear TrainY;
clear TrainXY;
clear TestX;
clear TestY;
clear size_sets;