
如何理解递归，写好递归函数
https://segmentfault.com/a/1190000038392459

青蛙跳台阶
单链表反转，递归，双指针
遍历树，前中后序
序列还原树

linkedlist
  queue,offer尾加，poll首加
  stack,push,pop
  dequeue,offer,poll,offerfirst,polllast
二叉树遍历，dfs前中后序，bfs层序，层序交替，先从左到右，再从右到左


递归：
70 爬楼梯
青蛙跳台阶 面试题10-11
斐波那契额 509
反转二叉树226
路径总和112
细胞分裂

分治，递归的孪生
求x的n次幂，O(lgn)
搜索二维矩阵II  240
求众数 169
合并k个排序链表  23

单调栈
给一个数组，返回的数组第i个位置的值应当是，对于原数组中的第i 个元素，至少往右走多少步，，才遇到比自己大的元素，没有找到是-1
public static int[] nextExceed(int[] input){
    int[] result = new int[input.length];
    Arrays.fill(result,-1);
    Deque<Integer> stack = new ArrayDeque<>();
    for (int i = 0; i < input.length; i++) {
        while (!stack.isEmpty() && input[i] > input[stack.peek()]){
            int top = stack.pop();
            result[top] = i-top;
        }
        stack.push(i);
    }
    return result;
}
int[] res = nextExceed(new int[]{5,3,1,2,4});
System.out.println(Arrays.toString(res));
柱状图最大矩形 84
最大矩形面积 85

并查集
朋友圈 547
684
200
737
1102
1135
261
1061
323

滑动窗口
1208340
1151
159


前缀和
560
523
974



差分
1094
1109
121
122
253


拓扑排序
210269

字符串
5
93
43
227
1055

二分查找
240
4
33

bfs广搜
127
139
752
130
317
505
529
1263
1197
815
934


dfs 深搜，回溯
934
113
124
1102
685
531
533
332
337

迷宫 dfs bfs
https://blog.csdn.net/qq_42500831/article/details/124697869
dfs 栈 递归
https://blog.csdn.net/include_IT_dog/article/details/89077780


动态规划
213
1043
416
123
62
63
651
361
1066
750
1230

贪心
452
1029
1231
45
621
376


字典树
单词压缩 820
Trie前缀树 208
单词替换 648
