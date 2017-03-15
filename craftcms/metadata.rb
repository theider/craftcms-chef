name "craftcms"
description "CraftCMS Web Server HTTP"
run_list(
    "recipe[apache2]",
    "recipe[apache2::mod_php]"
)
default_attributes(
    "apache" => {
    "listen" => ["*:80" ]
    }
)