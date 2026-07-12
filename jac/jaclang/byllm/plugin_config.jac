"""Plugin configuration hooks for jac-byllm.

The former JacByllmPluginConfig.get_plugin_metadata/get_config_schema hooks were
never dispatched (no loader, no test) and the schema had drifted stale versus the
live loader in config_loader.jac, so they were removed. The real [byllm] config
is read via jaclang.project.plugin_config.PluginConfigBase (see config_loader.jac).

# ponytail: module kept (not deleted) because it is a runtime_vendor seed
# (runtime_vendor.jac _BYLLM_SEEDS); drop that seed entry to delete this file.
"""
