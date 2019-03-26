# Unit tests for statistics sending client
# Run the tests by executing 'tox' after installing tox (sudo pip install tox)

from contrail_stats_client.main import Stats
import unittest


class StatsTestCase(unittest.TestCase):
    def setUp(self):
        class Vnc_client():
            def get_default_project_id():
                return "abcde"
            def virtual_machines_list():
                return {"virtual-machines": ["first", "second"]}
            def virtual_networks_list():
                return {"virtual-networks": ["first", "second"]}
            def virtual_routers_list():
                return {"virtual-routers": ["first", "second"]}
            def virtual_machine_interfaces_list():
                return {"virtual-machine-interfaces": ["first", "second"]}

        self.vnc_client = Vnc_client()
        self.stats = Stats(client=self.vnc_client)

    def tearDown(self):
        self.vnc_client = None

    def test_stats_init_vr(self):
        self.assertEqual(self.stats.vrouters, 2, "incorrect virtual routers number during statistics initialization")


if __name__ == '__main__':
    unittest.main()
