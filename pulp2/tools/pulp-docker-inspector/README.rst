pulp-docker-inspector
=====================

pulp-docker-inspector is a tool to map the relationships between content in a pulp docker
repository. It has 2 modes, `list` and `relation`.

List
****

Print the relationships heirarchy (top down) between content in the specified pulp repo.

.. code-block:: bash

   $ python pulp-docker-inspector.py test-fixture-1 --list

Partial Output::

   REPO: test-fixture-1
   TAG: manifest_b
       MANIFEST: sha256:b16ece3182c8386ab1fd001f4c69edaf984c728ad3561ba24d9e93193eb8e8c0
           BLOB: sha256:df5f2171d7a00260c6910231fd760f7b7d2afa576d1f2a674bf84496f1374e76
           BLOB: sha256:59add7b26d3a179ea3f653e7d4bb81250611f1408eb1effb2e50631a9da145c4
   TAG: manifest_a
       MANIFEST: sha256:04c27eb360809e1ea49c97fe8b8ca21d9f0ca7eb1be98030d1b539a76613470d
           BLOB: sha256:686209d53cbd832d0c9a5f77ae8acf87c58f7880581cf132f4022857d23e9182
           BLOB: sha256:242bb0431e380347dc02cecc616037a003d9ba9e1ae2fd62a3a874e4bdda1baf
   TAG: manifest_d
       MANIFEST: sha256:5921794fc03cba2162b314eea4755d074e06528a073ee4ab8cc54954dc7e0d89
           BLOB: sha256:357aff548189b13f3803b0ecf9c755eea235b89de0baa2838b10f7ff6217db13
           BLOB: sha256:0eccceb6824ea1a7e9a55ffe1145917af90a267e19324a178a659fe9cb0c6f8f
   TAG: manifest_c
       MANIFEST: sha256:6bda89d0d0772b03e4afb615e771b1c4ed8e76895ede8d7eede9b041ea4507e8
           BLOB: sha256:be6e7d2ac7b720bdc7aeacbc214a4587fb751509e04b12d9b20929c306b39401
   TAG: ml_iii
       MANIFESTLIST: sha256:c981478019c48aa00aa839ef5a73f551db0f9900fc2b1bd44b193c79dc3fe88b
           MANIFEST: sha256:04c27eb360809e1ea49c97fe8b8ca21d9f0ca7eb1be98030d1b539a76613470d
               BLOB: sha256:686209d53cbd832d0c9a5f77ae8acf87c58f7880581cf132f4022857d23e9182
               BLOB: sha256:242bb0431e380347dc02cecc616037a003d9ba9e1ae2fd62a3a874e4bdda1baf
           MANIFEST: sha256:d86b32899d0b6a0048e89dbf80fc8f673d2b262bbb22be6c6a780426d8539bae
               BLOB: sha256:be6e7d2ac7b720bdc7aeacbc214a4587fb751509e04b12d9b20929c306b39401
               BLOB: sha256:53519986d08c36bf136346b7435f95eac3dd6901eacdb7b7404a60caf5058419

Relation
********

Determine sharing relationships for a given manifest or manifest-list digest.

.. code-block:: bash

   $ python pulp-docker-inspector.py test-fixture-1 --relation sha256:b16ece3182c8386ab1fd001f4c69edaf984c728ad3561ba24d9e93193eb8e8c0

Partial Output::

   ********************MANIFESTS**************************************************

   MANIFEST: sha256:b16ece3182c8386ab1fd001f4c69edaf984c728ad3561ba24d9e93193eb8e8c0 shares with MANIFEST: sha256:3271612b344ab8807de8517b62c2dc07a65e3fdc2c703bf0bf3991b2f0604b0d:
       []
       NOT SHARED:2
   MANIFEST: sha256:b16ece3182c8386ab1fd001f4c69edaf984c728ad3561ba24d9e93193eb8e8c0 shares with MANIFEST: sha256:a56c2ade65aa090035aa70ac19d5a99606d2965a0782043ab332271be0c73eb4:
       [BLOB: sha256:df5f2171d7a00260c6910231fd760f7b7d2afa576d1f2a674bf84496f1374e76]
       NOT SHARED:1
   MANIFEST: sha256:b16ece3182c8386ab1fd001f4c69edaf984c728ad3561ba24d9e93193eb8e8c0 shares with MANIFEST: sha256:04c27eb360809e1ea49c97fe8b8ca21d9f0ca7eb1be98030d1b539a76613470d:
       []
       NOT SHARED:2
   MANIFEST: sha256:b16ece3182c8386ab1fd001f4c69edaf984c728ad3561ba24d9e93193eb8e8c0 shares with MANIFEST: sha256:b3afe9268760e106cd93782354bdd24a192fec3f910289d7ff4233665af95f9d:
       []
       NOT SHARED:2
   MANIFEST: sha256:b16ece3182c8386ab1fd001f4c69edaf984c728ad3561ba24d9e93193eb8e8c0 shares with MANIFEST: sha256:c5fc921c8a971793134160bc3ccc50454d7ba67aea36da44c74e91f8287216c6:
       []
       NOT SHARED:2
   MANIFEST: sha256:b16ece3182c8386ab1fd001f4c69edaf984c728ad3561ba24d9e93193eb8e8c0 shares with MANIFEST: sha256:b16ece3182c8386ab1fd001f4c69edaf984c728ad3561ba24d9e93193eb8e8c0:
       [BLOB: sha256:df5f2171d7a00260c6910231fd760f7b7d2afa576d1f2a674bf84496f1374e76, BLOB: sha256:59add7b26d3a179ea3f653e7d4bb81250611f1408eb1effb2e50631a9da145c4]
       NOT SHARED:0
