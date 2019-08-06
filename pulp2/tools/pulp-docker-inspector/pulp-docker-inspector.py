"""
A tool to explore the relationships in a local docker repository.
"""

import argparse
import json
import sys

from requests.auth import HTTPBasicAuth
import requests

AUTH = HTTPBasicAuth('admin', 'admin')
BASE_URL = 'https://pulp2.dev/pulp/api/v2'


class RepoContent():
    """Model a repository and all docker content within it."""

    def __init__(self, repo_id):
        """Register docker content of all types and make the lists accessible."""
        self.name = repo_id

        tag_dicts = retrieve_relationship_info(repo_id, "docker_tag")
        self.tags = [Tag(tag_dict, self) for tag_dict in tag_dicts]

        ml_dicts = retrieve_relationship_info(repo_id, "docker_manifest_list")
        self.manifest_lists = [ManifestList(ml_dict, self) for ml_dict in ml_dicts]

        manifest_dicts = retrieve_relationship_info(repo_id, "docker_manifest")
        self.manifests = [Manifest(manifest_dict, self) for manifest_dict in manifest_dicts]

        blob_dicts = retrieve_relationship_info(repo_id, "docker_blob")
        self.blobs = [Blob(blob_dict, self) for blob_dict in blob_dicts]

    def print_top_down(self):
        """Recursively print the content of a repository, showing the content relations."""
        print("REPO: {name}".format(name=self.name))
        for tag in self.tags:
            tag.print_top_down()


class Tag():
    """Dummy model for Docker Tags."""

    def __init__(self, tag_dict, repo):
        """Extract relevant info for a tag."""
        self.repo = repo
        self.name = tag_dict['metadata']['name']
        self.manifest_digest = tag_dict['metadata']['manifest_digest']
        self.manifest_type = tag_dict['metadata']['manifest_type']
        self.schema_version = tag_dict['metadata']['schema_version']

    @property
    def manifests_and_mls(self):
        """Manifests and Manifest Lists can be treated the same for tags. Retrieve both."""
        mls = [ml for ml in self.repo.manifest_lists if ml.digest == self.manifest_digest]
        manifests = [man for man in self.repo.manifests if man.digest == self.manifest_digest]
        return mls + manifests

    def __repr__(self):
        """Tags can be referenced by name."""
        return "TAG: {name}".format(name=self.name)

    def print_top_down(self):
        """Recursively print the content related to this tag, showing the content relations."""
        print(self)
        for tagged in self.manifests_and_mls:
            tagged.print_top_down(tab=4)

    def print_relations(self):
        """Recursively show relations of the tagged content."""
        print(self)
        for tagged in self.manifests_and_mls:
            tagged.print_relations()


class ManifestList():
    """Dummy model for Docker Manifest Lists."""

    def __init__(self, ml_dict, repo):
        """Create a dummy Docker Manifest List."""
        self.repo = repo
        self.digest = ml_dict['metadata']['digest']
        self._manifest_digests = [man['digest'] for man in ml_dict['metadata']['manifests']]

    def print_relations(self, other):
        """Recursively show relations of the manifest list."""
        print("{self} shares with {other}:".format(self=self, other=other))
        print("    " + str([man for man in self.manifests if man in other.manifests]))
        print("    NOT SHARED:" + str(len(
            [man for man in self.manifests if man not in other.manifests]
        )))

    @property
    def manifests(self):
        """Retrieve manifests associated with this Manifest List."""
        return [man for man in self.repo.manifests if man.digest in self._manifest_digests]

    def __repr__(self):
        """Manifest Lists can be referenced by sha256 digest."""
        return "MANIFESTLIST: {digest}".format(digest=self.digest)

    def print_top_down(self, tab=None):
        """Recursively print the content related to this manifest list, showing the relations."""
        print(" " * tab + repr(self))
        if not tab:
            tab = 0
        for manifest in self.manifests:
            manifest.print_top_down(tab=tab+4)


class Manifest():
    """Dummy model for Docker Manifests."""

    def __init__(self, manifest_dict, repo):
        """Create a dummy Docker Manifest."""
        self.repo = repo
        self.digest = manifest_dict['metadata']['digest']
        self._blob_sums = [layer['blob_sum'] for layer in manifest_dict['metadata']['fs_layers']]
        self.config_digest = None

        if manifest_dict['metadata']['schema_version'] == 2:
            self.config_digest = manifest_dict['metadata']['config_layer']

    def __repr__(self):
        """Manifests can be referenced by sha256 digest."""
        return "MANIFEST: {digest}".format(digest=self.digest)

    @property
    def blobs(self):
        """Retrieve blobs associated with this Manifest."""
        blobs = [blob for blob in self.repo.blobs if blob.digest in self._blob_sums]
        config_blobs = [blob for blob in self.repo.blobs if blob.digest == self.config_digest]
        return blobs + config_blobs

    def print_top_down(self, tab=None):
        """Recursively print the content related to this manifest, showing the content relations."""
        if not tab:
            tab = 0
        print(" " * tab + repr(self))
        for blob in self.blobs:
            blob.print_top_down(tab=tab+4)

    def print_relations(self, other):
        """Recursively show relations of the manifest."""
        print("{self} shares with {other}:".format(self=self, other=other))
        print("    " + str([blob for blob in self.blobs if blob in other.blobs]))
        print("    NOT SHARED:" + str(len(
            [blob for blob in self.blobs if blob not in other.blobs]
        )))


class Blob():
    """Dummy model for Docker Blobs (aka layers)."""

    def __init__(self, blob_dict, repo):
        """Create a dummy Docker Blob."""
        self.repo = repo
        self.digest = blob_dict['metadata']['digest']

    def __repr__(self):
        """Blobs can be referenced by sha256 digest."""
        return "BLOB: {digest}".format(digest=self.digest)

    def print_top_down(self, tab=None):
        """Recursively print the content related to this manifest, showing the content relations."""
        if not tab:
            tab = 0
        print(" " * tab + repr(self))


def retrieve_relationship_info(repo_id, content_type):
    """Hit the Pulp API and retrieve content info by type."""
    criteria = {"type_ids": [content_type], "filters": {}}
    req = requests.post(
        url='{base}/repositories/{repo}/search/units/'.format(base=BASE_URL, repo=repo_id),
        data=json.dumps({"criteria": criteria}),
        auth=AUTH,
    )
    return json.loads(req.content)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Map the contents of a docker repo.')
    parser.add_argument('repo_id')
    parser.add_argument("--list", action="store_true")
    parser.add_argument("--relation")
    args = parser.parse_args()
    test_repo = RepoContent(args.repo_id)
    if args.list:
        test_repo.print_top_down()
    if args.relation:
        this = None
        for ml in test_repo.manifest_lists:
            if ml.digest == args.relation:
                this = ml
                break
        if this:
            print
            print("********************MANIFEST_LISTS*********************************************")
            print
            for other_ml in test_repo.manifest_lists:
                this.print_relations(other_ml)
            sys.exit(0)

        for manifest in test_repo.manifests:
            if manifest.digest == args.relation:
                this = manifest
                break
        if this:
            print
            print("********************MANIFESTS**************************************************")
            print
            for other_manifest in test_repo.manifests:
                this.print_relations(other_manifest)
            sys.exit(0)
        else:
            print("NOT FOUND {dig}".format(dig=args.relation))
            sys.exit(1)
