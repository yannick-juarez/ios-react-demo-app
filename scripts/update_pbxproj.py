#!/usr/bin/env python3
"""
Updates project.pbxproj to add 7 local SPM packages to the Xcode project.
"""

import re

PBXPROJ = "/Users/yannickjuarez/Developer/BeReal/ios-react-demo-app/React.xcodeproj/project.pbxproj"

# ─── GUIDs ────────────────────────────────────────────────────────────────────
# XCLocalSwiftPackageReference (7)
PKG_REF = {
    "CoreDomain":         "2B01000A2FAA000000000001",
    "CorePersistence":    "2B01000A2FAA000000000002",
    "CoreInfrastructure": "2B01000A2FAA000000000003",
    "DesignSystem":       "2B01000A2FAA000000000004",
    "CameraFeature":      "2B01000A2FAA000000000005",
    "ReactionFeature":    "2B01000A2FAA000000000006",
    "ShareImportFeature": "2B01000A2FAA000000000007",
}

# XCSwiftPackageProductDependency for React target (7)
PROD_DEP_REACT = {
    "CoreDomain":         "2B02000A2FAA000000000001",
    "CorePersistence":    "2B02000A2FAA000000000002",
    "CoreInfrastructure": "2B02000A2FAA000000000003",
    "DesignSystem":       "2B02000A2FAA000000000004",
    "CameraFeature":      "2B02000A2FAA000000000005",
    "ReactionFeature":    "2B02000A2FAA000000000006",
    "ShareImportFeature": "2B02000A2FAA000000000007",
}

# XCSwiftPackageProductDependency for ShareExtension target (1)
PROD_DEP_SHARE = {
    "ShareImportFeature": "2B03000A2FAA000000000007",
}

# PBXBuildFile refs — React Frameworks phase (7)
BUILD_FILE_REACT = {
    "CoreDomain":         "2B04000A2FAA000000000001",
    "CorePersistence":    "2B04000A2FAA000000000002",
    "CoreInfrastructure": "2B04000A2FAA000000000003",
    "DesignSystem":       "2B04000A2FAA000000000004",
    "CameraFeature":      "2B04000A2FAA000000000005",
    "ReactionFeature":    "2B04000A2FAA000000000006",
    "ShareImportFeature": "2B04000A2FAA000000000007",
}

# PBXBuildFile refs — ShareExtension Frameworks phase (1)
BUILD_FILE_SHARE = {
    "ShareImportFeature": "2B05000A2FAA000000000007",
}

PACKAGES = list(PKG_REF.keys())

with open(PBXPROJ) as f:
    src = f.read()

# ─── 1. Add PBXBuildFile entries ───────────────────────────────────────────────
new_build_files = ""
for pkg in PACKAGES:
    new_build_files += f"\t\t{BUILD_FILE_REACT[pkg]} /* {pkg} in Frameworks */ = {{isa = PBXBuildFile; productRef = {PROD_DEP_REACT[pkg]} /* {pkg} */; }};\n"
new_build_files += f"\t\t{BUILD_FILE_SHARE['ShareImportFeature']} /* ShareImportFeature in Frameworks */ = {{isa = PBXBuildFile; productRef = {PROD_DEP_SHARE['ShareImportFeature']} /* ShareImportFeature */; }};\n"

src = src.replace(
    "/* End PBXBuildFile section */",
    new_build_files + "/* End PBXBuildFile section */"
)

# ─── 2. Remove invalid exception set (files moved to packages) ─────────────────
# Remove reference from the React fileSystemSynchronizedRootGroup
src = src.replace(
    "\t\t\t\t270FFEC32F9FC9B200FA0FD7 /* Exceptions for \"React\" folder in \"ShareExtension\" target */,\n",
    ""
)
# Remove the exception set definition block
exception_block = """\t\t270FFEC32F9FC9B200FA0FD7 /* Exceptions for "React" folder in "ShareExtension" target */ = {
\t\t\tisa = PBXFileSystemSynchronizedBuildFileExceptionSet;
\t\t\tmembershipExceptions = (
\t\t\t\tDomain/Models/React/React.swift,
\t\t\t\t"Domain/Models/React/React+Samples.swift",
\t\t\t\tDomain/Models/User/User.swift,
\t\t\t\t"Domain/Models/User/User+Samples.swift",
\t\t\t);
\t\t\ttarget = 27E2FCAA2F9F988E00FD7F7B /* ShareExtension */;
\t\t};"""
src = src.replace(exception_block, "")

# ─── 3. Add frameworks to React Frameworks build phase ────────────────────────
react_frameworks = ""
for pkg in PACKAGES:
    react_frameworks += f"\t\t\t\t{BUILD_FILE_REACT[pkg]} /* {pkg} in Frameworks */,\n"

src = src.replace(
    "\t\t\t\t271A009C2F9E48BF00B5CF30 /* NukeUI in Frameworks */,\n",
    f"\t\t\t\t271A009C2F9E48BF00B5CF30 /* NukeUI in Frameworks */,\n{react_frameworks}"
)

# ─── 4. Add ShareImportFeature to ShareExtension Frameworks build phase ───────
src = src.replace(
    # ShareExtension Frameworks phase - currently empty files list (27E2FCA82F9F988E00FD7F7B)
    "27E2FCA82F9F988E00FD7F7B /* Frameworks */ = {\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n",
    f"27E2FCA82F9F988E00FD7F7B /* Frameworks */ = {{\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t\t{BUILD_FILE_SHARE['ShareImportFeature']} /* ShareImportFeature in Frameworks */,\n\t\t\t);\n"
)

# ─── 5. Add local package refs to PBXProject packageReferences ────────────────
local_pkg_refs = ""
for pkg in PACKAGES:
    local_pkg_refs += f"\t\t\t\t{PKG_REF[pkg]} /* XCLocalSwiftPackageReference \"Packages/{pkg}\" */,\n"

src = src.replace(
    "\t\t\tpackageReferences = (\n\t\t\t\t271A009A2F9E48BF00B5CF30 /* XCRemoteSwiftPackageReference \"Nuke\" */,\n\t\t\t);",
    f"\t\t\tpackageReferences = (\n\t\t\t\t271A009A2F9E48BF00B5CF30 /* XCRemoteSwiftPackageReference \"Nuke\" */,\n{local_pkg_refs}\t\t\t);"
)

# ─── 6. Add packageProductDependencies to React target ───────────────────────
react_prod_deps = ""
for pkg in PACKAGES:
    react_prod_deps += f"\t\t\t\t{PROD_DEP_REACT[pkg]} /* {pkg} */,\n"

src = src.replace(
    "\t\t\tpackageProductDependencies = (\n\t\t\t\t271A009B2F9E48BF00B5CF30 /* NukeUI */,\n\t\t\t);",
    f"\t\t\tpackageProductDependencies = (\n\t\t\t\t271A009B2F9E48BF00B5CF30 /* NukeUI */,\n{react_prod_deps}\t\t\t);"
)

# ─── 7. Add packageProductDependencies to ShareExtension target ──────────────
src = src.replace(
    # ShareExtension target's empty packageProductDependencies
    "\t\t\tname = ShareExtension;\n\t\t\tpackageProductDependencies = (\n\t\t\t);\n",
    f"\t\t\tname = ShareExtension;\n\t\t\tpackageProductDependencies = (\n\t\t\t\t{PROD_DEP_SHARE['ShareImportFeature']} /* ShareImportFeature */,\n\t\t\t);\n"
)

# ─── 8. Add XCSwiftPackageProductDependency entries ──────────────────────────
new_product_deps = ""
for pkg in PACKAGES:
    new_product_deps += f"""\t\t{PROD_DEP_REACT[pkg]} /* {pkg} */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {PKG_REF[pkg]} /* XCLocalSwiftPackageReference "Packages/{pkg}" */;
\t\t\tproductName = {pkg};
\t\t}};
"""
new_product_deps += f"""\t\t{PROD_DEP_SHARE['ShareImportFeature']} /* ShareImportFeature */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {PKG_REF['ShareImportFeature']} /* XCLocalSwiftPackageReference "Packages/ShareImportFeature" */;
\t\t\tproductName = ShareImportFeature;
\t\t}};
"""

src = src.replace(
    "/* End XCSwiftPackageProductDependency section */",
    new_product_deps + "/* End XCSwiftPackageProductDependency section */"
)

# ─── 9. Add XCLocalSwiftPackageReference section ─────────────────────────────
local_pkg_section = "\n/* Begin XCLocalSwiftPackageReference section */\n"
for pkg in PACKAGES:
    local_pkg_section += f"""\t\t{PKG_REF[pkg]} /* XCLocalSwiftPackageReference "Packages/{pkg}" */ = {{
\t\t\tisa = XCLocalSwiftPackageReference;
\t\t\trelativePath = Packages/{pkg};
\t\t}};
"""
local_pkg_section += "/* End XCLocalSwiftPackageReference section */\n"

src = src.replace(
    "\n/* Begin XCRemoteSwiftPackageReference section */",
    local_pkg_section + "\n/* Begin XCRemoteSwiftPackageReference section */"
)

# ─── 10. Update AppDemo path → Apps/ReactionApp ──────────────────────────────
# ─── 10. Add Apps/ReactionApp as a new fileSystemSynchronizedRootGroup ─────────
# New GUID for Apps/ReactionApp group
APPS_GUID = "2B06000A2FAA000000000001"

# Add the group definition in PBXFileSystemSynchronizedRootGroup section
src = src.replace(
    "/* End PBXFileSystemSynchronizedRootGroup section */",
    f"\t\t{APPS_GUID} /* Apps/ReactionApp */ = {{\n\t\t\tisa = PBXFileSystemSynchronizedRootGroup;\n\t\t\tpath = Apps/ReactionApp;\n\t\t\tsourceTree = \"<group>\";\n\t\t}};\n/* End PBXFileSystemSynchronizedRootGroup section */"
)

# Add it to the top-level PBXGroup children
src = src.replace(
    "\t\t\t\t27E2FCFF2F9FAB3F00FD7F7B /* Shared */,\n\t\t\t\t271AFEDF2F9E2CFC00B5CF30 /* React */,",
    f"\t\t\t\t{APPS_GUID} /* Apps/ReactionApp */,\n\t\t\t\t27E2FCFF2F9FAB3F00FD7F7B /* Shared */,\n\t\t\t\t271AFEDF2F9E2CFC00B5CF30 /* React */,"
)

# Add it to the React target's fileSystemSynchronizedGroups
src = src.replace(
    "\t\t\t\tfileSystemSynchronizedGroups = (\n\t\t\t\t\t271AFEDF2F9E2CFC00B5CF30 /* React */,\n\t\t\t\t);",
    f"\t\t\t\tfileSystemSynchronizedGroups = (\n\t\t\t\t\t{APPS_GUID} /* Apps/ReactionApp */,\n\t\t\t\t\t271AFEDF2F9E2CFC00B5CF30 /* React */,\n\t\t\t\t);"
)

# ─── 11. Fix Share → ShareExtension folder path ─────────────────────────────────
src = src.replace(
    "\t\t27E2FCAC2F9F988E00FD7F7B /* Share */ = {\n\t\t\tisa = PBXFileSystemSynchronizedRootGroup;\n\t\t\texceptions = (\n\t\t\t\t27E2FCB92F9F988E00FD7F7B /* Exceptions for \"Share\" folder in \"Share\" target */,\n\t\t\t);\n\t\t\tpath = Share;",
    "\t\t27E2FCAC2F9F988E00FD7F7B /* Share */ = {\n\t\t\tisa = PBXFileSystemSynchronizedRootGroup;\n\t\t\texceptions = (\n\t\t\t\t27E2FCB92F9F988E00FD7F7B /* Exceptions for \"Share\" folder in \"Share\" target */,\n\t\t\t);\n\t\t\tpath = ShareExtension;"
)

with open(PBXPROJ, "w") as f:
    f.write(src)

print("✅ project.pbxproj updated successfully.")

# ─── Verify key strings are present ──────────────────────────────────────────
assert "XCLocalSwiftPackageReference" in src, "Local package refs missing"
assert "CoreDomain" in src, "CoreDomain missing"
assert "ShareImportFeature in Frameworks" in src, "ShareImportFeature framework missing"
print("✅ Verification passed.")
