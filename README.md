Use rsync for the Boxes where the mount command fails:

```ruby
config.vm.synced_folder ".", "/vagrant", type: "rsync"
```
