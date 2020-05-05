function f = genetic_algorithm(D, mute, Pm)
% �Ŵ��㷨����й�ʡ�����TSP����ļ�ʵ��
% ����̨������ۣ�����
clear;
if ~exist('mute', 'var')
    mute = 0; % �Ƿ���ʾ������ʾ��Ϣ
end
if ~exist('Pm', 'var')
    Pm = 0.2; % ������ʣ�Խ������Խ�����ǽ�һ��Խ��
end
if ~exist('D', 'var')
   data=xlsread('ʡ�ᾭγ����.xlsx');
    C=data;
    D=zeros(35,35);% DΪ���м�ľ������
    % �γ�����֮���Ӧ�ľ��󣨶Գ��󣬿���ֻ�������ǻ������ǣ�
    [LA1,LA2]=meshgrid(C(:,2));
    [LO1,LO2]=meshgrid(C(:,1));

    % ��������֮��ľ��룬��λΪ����
    R = distance(LA1,LO1,LA2,LO2,almanac('earth','wgs84'));
    D = num2str(R,'%10.2f');
    %disp(D);
end
rng(1);
n = size(D, 1);
N = 100; % Ⱥ���ģ
TOL = 20; % ������̴���(����TOL��rate�����������Ҳ������Ž⣬��ֹͣ����)

solutions = zeros(N, n);
fs = zeros(N, 1);
for i = 1:N
    solutions(i, :) = [1, randperm(n-1) + 1]; % ����N���⣬�ٶ���1��ʼ
    fs(i) = TSP_distance(D, solutions(i, :));
end
Pu = max(fs) - fs + 1;
P = Pu/sum(Pu);
cumP = cumsum(P);
best = min(fs);
avg = mean(fs);
rate = best/avg;
if ~mute
disp('��ʼ���Ⱥ������̵�·������Ϊ��');
disp(best);
disp('��ʼ���Ⱥ����ƽ��·������Ϊ��');
disp(avg);
end

tol = 0;
count = 0;
while 1
    count = count + 1;
    if ~mute
        fprintf('��ǰ��%d�ε���\n', count);
    end
    parents = zeros(size(solutions));
    for i = 1:N % ʹ�����̶ĵķ�ʽѡ��������Ⱦɫ��
        index = sum(cumP <= rand) + 1;
        parents(i, :) = solutions(index, :);
    end
    new_solutions = zeros(size(solutions));
    assert(mod(N, 2) == 0);
    for i = 1:N/2 % �������������Ĭ��NΪż����ÿ��������һ����������Ӵ�
        % �������Ӵ�1ȡ����1��ǰһ��Ⱦɫ�壬��һ�����ɸ���2�ṩ��ͬ�����Ӵ�2
        p1 = parents(2*i-1, :);
        p2 = parents(2*i, :);
        middle = ceil(n/2);
        s1 = p1(1:middle);
        res1 = setdiff(p2, s1, 'stable');
        s1 = [s1, res1];
        s2 = p2(1:middle);
        res2 = setdiff(p1, s2, 'stable');
        s2 = [s2, res2];
        new_solutions(2*i-1, :) = s1;
        new_solutions(2*i, :) = s2;
    end
    for i = 1:N % �������������ķ�ʽΪ���ȡ�������е�˳�򽻻�
        if rand < Pm
            temp = randperm(n-1) + 1;
            k = temp(1);
            new_solutions(i, [1, k]) = new_solutions(i, [k, 1]);
        end
    end
    % ���ˣ��µ���Ⱥ�Ѿ�������ϣ��������Ⱥ��ʼ��һ�ֵļ���
    solutions = new_solutions;
    for i = 1:N
        fs(i) = TSP_distance(D, solutions(i, :));
    end
    Pu = max(fs) - fs + 1;
    P = Pu/sum(Pu);
    cumP = cumsum(P);
    best_new = min(fs);
    avg = mean(fs);
    rate_new = best_new/avg;
    if ~mute
        disp('��̵�·������Ϊ��');
        disp(best_new);
        disp('ƽ����·������Ϊ��');
        disp(avg);
    end
    tol = tol + 1;
    if best_new < best || rate_new > rate
        best = best_new;
        rate = rate_new;
        tol = 0;
    end
    if tol >= TOL
        break
    end
    if count > 5000
        break
    end
end
[f, index] = min(fs);
solution = solutions(index, :);
if ~mute
fprintf('��������õ�������·��Ϊ��\n');
disp(solution);
disp('·������Ϊ��');
disp(f);
end

function f = TSP_distance(D, solution)
% �������������solution�ľ��룬���г���֮��ľ�����D������
n = numel(solution);
sum = 0;
for i = 1:n-1
    sum = sum + D(solution(i), solution(i+1));
end
sum = sum + D(solution(n), solution(1));
f = sum;