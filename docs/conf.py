"""Sphinx configuration for the project documentation."""

from __future__ import annotations

import os
from datetime import datetime, timezone
from pathlib import Path


DOCS_DIR = Path(__file__).resolve().parent

project = "C++ Embedded Linux Repository Template"
author = "C++ Embedded Linux Repository Template contributors"
copyright = f"{datetime.now(timezone.utc).year}, {author}"

release = os.environ.get("PROJECT_VERSION", "0.1.0")
version = release

extensions = [
    "breathe",
    "myst_parser",
    "sphinxcontrib.mermaid",
]

source_suffix = {
    ".md": "markdown",
}
root_doc = "index"
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "substitution",
    "tasklist",
]
myst_fence_as_directive = ["mermaid"]
myst_heading_anchors = 3

# Keep the published site deterministic instead of following Mermaid's moving "latest" tag.
mermaid_version = "11.12.1"

primary_domain = "cpp"
highlight_language = "cpp"

xml_setting = Path(
    os.environ.get("DOXYGEN_XML_DIR", "../build/docs/doxygen/xml")
)
if not xml_setting.is_absolute():
    xml_setting = (DOCS_DIR / xml_setting).resolve()

breathe_projects = {project: str(xml_setting)}
breathe_default_project = project
breathe_domain_by_extension = {
    "h": "cpp",
    "hh": "cpp",
    "hpp": "cpp",
    "hxx": "cpp",
    "c": "c",
    "cc": "cpp",
    "cpp": "cpp",
    "cxx": "cpp",
}

html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]
html_css_files = ["css/custom.css"]
html_title = f"{project} {release}"
html_show_sourcelink = False
html_show_sphinx = False

linkcheck_ignore = [
    r"http://localhost(?::\d+)?/.*",
    r"ssh://.*",
]
