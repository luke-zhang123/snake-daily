

- [github 配置多个ssh key](https://gist.github.com/jexchan/2351996)

使用上面配置完ssh config, 需要用ssh config里配置的host，类型"github.com-activehacker"替代"github.com"，这样ssh才能识别到正确的key

```
~/.ssh/config
#activehacker account
Host github.com-activehacker
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_rsa_activehacker

#jexchan account
Host github.com-jexchan
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_rsa_jexchan
```

```
git clone <Host in ssh config>:<github username>/<github repo name>.git
```

测试ssh访问，debug

`ssh -T git@github.com-activehacker`

`ssh -Tv git@github.com-activehacker`


- create a new repository on the command line

```
echo "# mydata" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:luke-zhang123/mydata.git
git push -u origin main
```
- push an existing repository from the command line

```
git remote add origin git@github.com:luke-zhang123/mydata.git
git branch -M main
git push -u origin main
```

- 看远程库

`git remote -v`

