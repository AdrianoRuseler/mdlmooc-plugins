# mdlmooc-plugins
Moodle MOOC Plugins

## Upgrade Submodules
```bash
git submodule update --remote
```
## Disable Notifications

```php
 // Moodle configuration file
 
// Use the following flag to completely disable the installation of plugins
// (new plugins, available updates and missing dependencies) and related
// features (such as cancelling the plugin installation or upgrade) via the
// server administration web interface.
$CFG->disableupdateautodeploy = true;
// Disabling update notifications
$CFG->disableupdatenotifications = true;
```
## References
https://www.vogella.com/tutorials/GitSubmodules/article.html


## Plugins List

```bash
mkdir moodle
cd moodle
```

- https://github.com/markn86/moodle-mod_customcert
```bash
git submodule add -b MOODLE_310_STABLE https://github.com/markn86/moodle-mod_customcert.git mod/customcert
```

- https://github.com/danmarsden/moodle-mod_attendance/
```bash
git submodule add -b main https://github.com/danmarsden/moodle-mod_attendance.git mod/attendance
```

- https://github.com/blindsidenetworks/moodle-mod_bigbluebuttonbn
```bash
git submodule add -b v2.3-stable https://github.com/blindsidenetworks/moodle-mod_bigbluebuttonbn.git mod/bigbluebuttonbn
```
- https://github.com/FMCorz/moodle-block_xp
```bash
git submodule add -b master https://github.com/FMCorz/moodle-block_xp.git blocks/xp
```
- https://github.com/deraadt/moodle-block_completion_progress
```bash
git submodule add -b master https://github.com/deraadt/moodle-block_completion_progress.git blocks/completion_progress
```
- https://github.com/ndunand/moodle-mod_choicegroup
```bash
git submodule add -b master https://github.com/ndunand/moodle-mod_choicegroup.git mod/choicegroup
```
- https://github.com/dthies/moodle-atto_fullscreen
```bash
git submodule add -b master https://github.com/dthies/moodle-atto_fullscreen.git lib/editor/atto/plugins/fullscreen
```

- https://github.com/frankkoch/moodle-mod_studentquiz
```bash
git submodule add -b master https://github.com/frankkoch/moodle-mod_studentquiz.git mod/studentquiz
```

- https://github.com/mikasmart/moodle-report_benchmark
```bash
git submodule add -b master https://github.com/mikasmart/moodle-report_benchmark.git report/benchmark
```
- https://github.com/moodlehq/moodle-tool_migratehvp2h5p
```bash
git submodule add -b master https://github.com/moodlehq/moodle-tool_migratehvp2h5p.git admin/tool/migratehvp2h5p
```



## Themes List

- https://github.com/willianmano/moodle-theme_moove
```bash
git submodule add -b master https://github.com/willianmano/moodle-theme_moove.git theme/moove
```


- https://gitlab.com/jezhops/moodle-theme_adaptable
```bash
git submodule add -b master https://gitlab.com/jezhops/moodle-theme_adaptable.git theme/adaptable
```

- https://github.com/dbnschools/moodle-theme_fordson
```bash
git submodule add -b master https://github.com/dbnschools/moodle-theme_fordson.git theme/fordson
```

- https://github.com/lmsace/academi 
```bash
git submodule add -b v3.8 https://github.com/lmsace/academi.git theme/academi
```

- https://github.com/lmsace/klass

```bash
git submodule add -b v3.8 https://github.com/lmsace/klass.git theme/klass
```

- https://github.com/lmsace/eguru

```bash
git submodule add -b v3.8 https://github.com/lmsace/eguru.git theme/eguru
```

## Removed

- https://github.com/michael-milette/moodle-local_mailtest
```bash
git submodule add -b master https://github.com/michael-milette/moodle-local_mailtest.git local/mailtest
```

- https://github.com/trema-tech/moodle-theme_trema

```bash
git submodule add -b MOODLE_38_STABLE https://github.com/trema-tech/moodle-theme_trema.git theme/trema
```
