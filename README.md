# chikungunya_simulation
Abstract:
Mosquito-borne diseases, such as chikungunya, dengue, and malaria, are re-emerging and expanding to new and formerly unaffected places, leading to a need for models which can track their evolution and thus help with public policy and epidemiological studies. Such diseases' evolution is driven by the interactions between hosts and vectors, and is thus heavily dependent on factors like host and vector population distributions and mobility, and geographical and weather conditions. Traditionally used mathematical models fail to capture such issues, thereby creating a gap between what epidemiologists and disease modelers can provide, and what public health policy requires. We give a generalized agent-based model (ABM) which overcomes these limitations by careful integration of geographic information (GIS) and census data to account for the spatial movement of infections, and climate data to capture the temporal nature of an epidemic. It captures the disorganized interactions of hosts and vectors at a micro-scale by explicitly modeling each human and mosquito to simulate the complex trajectories of disease outbreaks (even those have yet to occur), and makes it possible to test the efficacy of various public health policies. This model also suggests that it is possible to estimate hard-to-determine parameters about vectors (e.g., a mosquito's sensing distance), through simple model calibration. Unlike previous solutions, our model is trained and validated using real data from a 2013-14 chikungunya epidemic in the Caribbean and is seen to give accurate results.

Link to our AAMAS publication: http://www.aamas2017.org/proceedings/pdfs/p426.pdf

{Akshay Jindal and Shrisha Rao. 2017. Agent-Based Modeling and Simulation of Mosquito-Borne Disease Transmission. In Proceedings of the 16th Conference on Autonomous Agents and MultiAgent Systems (AAMAS '17). International Foundation for Autonomous Agents and Multiagent Systems, Richland, SC, 426-435.}

Installation:
1) Download and Install Gama Platform v1.8 (https://gama-platform.github.io/download)
2) Clone this repo and import in the Game workspace
3) Run the model in GAMAProject/models/SI_city1_chikungunya.gaml
4) Tune the parameters as required. (Note: Model here may not be tuned to the values in the paper)
