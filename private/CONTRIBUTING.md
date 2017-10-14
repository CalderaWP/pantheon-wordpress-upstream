# Contributing to cftesting.taco

## Dev Setup

The site was designed to get up and running quickly via [varying-vagrant-vagrants][2].

So to get started, follow the [First Vagrant Up][3] instructions, including:

```bash
git clone git@github.com:Varying-Vagrant-Vagrants/VVV.git vvv
cd vvv
vagrant up --provision
```

Once you can verify that `local.wordpress.dev` is accessible on your local system, then you can proceed to add this cftesting.taco repo:

```bash
cd www
git clone --recursive git@github.com:xwp/cftesting.taco.git cftesting.taco
cd cftesting.taco
```

You can then reboot Vagrant to cause the newly added site to be initialized:

```bash
vagrant reload --provision
```

Once this finishes, you should be able to access **[vvv.cftesting.taco](http://vvv.cftesting.taco/)** from your browser. The default WordPress username and password is `dev`.

If commands complain about needing to be run in Vagrant, you first can `vagrant ssh` then `cd /srv/www/cftesting.taco`
to run the command, or do:

```bash
vagrant -c 'cd /srv/www/cftesting.taco && wp some command'
```

You can tail the error log in VVV by invoking the bundled script from your host machine:

```bash
bash private/tail-vvv-php-error-log.sh
```

## Upgrading

Pantheon will prompt you when there are upstream updates for WordPress Core to install. If there is a conflict (e.g. in `README.md`) then you can manually merge from the upstream via:

```bash
git remote add upstream https://github.com/pantheon-systems/WordPress.git
git checkout master
git pull -X mine upstream master
git checkout origin/master -- readme.html # any files that you modified
git diff --staged # sanity check
git commit
git push origin master
```

There is a script for updating plugins. You can define the plugins from WordPress.org to keep updated by creating a file `private/wordpress-org-plugins.txt` which contains a list of the slugs you want to update:

```
wp-redis
jetpack
customize-widgets-plus
```

You can then run [`private/update.sh`](private/update.sh) inside of Vagrant (you'll want to make sure you have first [set your git identity](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup#Your-Identity) inside of Vagrant).

Any additional update logic can be committed to `private/update-custom.sh`.

You can also get the latest from this repo via:

```bash
git pull https://github.com/xwp/pantheon-wordpress-upstream.git master
```

## Public Environments and Deployments

The site is hosted with Pantheon.

You can deploy code to the dev site [`dev-cftesting.pantheon.io`](http://dev-cftesting.pantheon.io/) by pushing commits to the `master` branch on the Pantheon repo.
(Ideally, however, this GitHub repo is set up with Travis CI to push commits to Pantheon when builds pass.)
To push directly to Pantheon, first make sure you first [add your SSH key to your Pantheon account](https://pantheon.io/docs/articles/users/generating-ssh-keys/#add-the-key-to-your-pantheon-account), and then
you can add the Pantheon repo as a remote on you existing GitHub clone:

```bash
git remote add pantheon ssh://codeserver.dev.123e4567-e89b-12d3-a456-426655440000@codeserver.dev.123e4567-e89b-12d3-a456-426655440000.drush.in:2222/~/repository.git
```

Then you can deploy simply by merging any feature branches into the `master` branch on GitHub (via pull request), and then just do:

```bash
git checkout master && git pull origin && git push pantheon
```

You can then [promote the code](https://dashboard.pantheon.io/sites/123e4567-e89b-12d3-a456-426655440000#test/deploys) to the [test environment](http://test-cftesting.pantheon.io/) before deploying it to production via the Pantheon dashboard.

Power users will want to check out the [Pantheon CLI](https://github.com/pantheon-systems/cli) which allows you to do a lot of [administrative functions](https://github.com/pantheon-systems/cli/wiki/Available-Commands) (including deployments) as well as any WP-CLI command. To do a deployment to staging (test), for instance:

```bash
terminus site deploy --site=cftesting --env=test --from=dev
```

## Production site info

The production site is located at [https://cftesting.taco/](https://cftesting.taco/)

[2]: https://github.com/Varying-Vagrant-Vagrants/VVV
[3]: https://github.com/Varying-Vagrant-Vagrants/VVV#the-first-vagrant-up
[4]: https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards
[5]: https://github.com/gulpjs/gulp
