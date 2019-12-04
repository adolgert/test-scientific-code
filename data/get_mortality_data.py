# This retrieves mortality rates from IHME's database.
# Run this first in order to get access to db_queries.
# source /ihme/code/central_comp/miniconda/bin/activate gbd_env
from db_queries import get_envelope, get_age_metadata

gbd_round=5
population = get_envelope(age_group_id="all", location_id="all", sex_id=1,
                  gbd_round_id=gbd_round)
mortality_rate = get_envelope(age_group_id="all", location_id="all", sex_id=1,
                              gbd_round_id=gbd_round, rates=1)
ages = get_age_metadata(age_group_set_id=12, gbd_round_id=gbd_round)

mortality_rate.to_hdf("mortality.h5", "mortality", format="table", append=False)
mortality_rate.to_csv("mortality.csv", index=False)
population.to_hdf("mortality.h5", "population", format="table", append=False)
population.to_csv("population.csv", index=False)
ages.to_hdf("mortality.h5", "ages", format="table", append=False)
ages.to_csv("ages.csv", index=False)
