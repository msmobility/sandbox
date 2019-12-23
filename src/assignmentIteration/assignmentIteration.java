package assignmentIteration;

/**
 * Program to run iterative assignment across three links
 */
public class assignmentIteration {

    // main class
    private static float alpha;
    private static float beta;
    private static float demand;

    public static void main(String[] args) {
        // run method

        System.out.println("Model to find an equilibrium on a three-route assignment");
        int iter = 1;
        String[] routeNames = {"Route 3", "Route 14", "Route 60"};
        float[] freeFlow = {49f, 80f, 44f};
        float[] capacity = {950f, 2200f, 600f};
        alpha = 0.45f;
        beta = 6f;
        demand = 2600f;

        float[] volumes =  getVolumesAON(freeFlow);
        System.out.println("Path,FreeFlowTime,Capacity,Volume,CongestedTime");

        float[] congestedTime = new float[3];
        for (int route = 0; route < 3; route++) {
            congestedTime[route] = getCongestedTime(freeFlow[route], capacity[route], volumes[route]);
        }

        for (int route = 0; route < 3; route++) {
            System.out.println(routeNames[route]+","+freeFlow[route]+","+capacity[route]+","+volumes[route]+","+congestedTime[route]);
        }

        boolean equilibriumFound = false;
        do {
            iter++;
            float[] volumesThisIter = getVolumesAON(congestedTime);
            float[] volumesMSA = new float[3];
            float[] timeThisIter = new float[3];

            System.out.println("Iteration " + iter);
            System.out.println("Path,VolumeAON,VolumeMSA,CongestedTime");

            for (int route = 0; route < 3; route++) {
                volumesMSA[route] = volumesThisIter[route] * 1f/((float) iter) + volumes[route] * (1f-1f/((float) iter));
//                System.out.println("***");
//                System.out.println(volumesThisIter[route]);
//                System.out.println(1f/((float) iter));
//                System.out.println(volumes[route]);
//                System.out.println((1f-1f/((float) iter)));
//                System.out.println(volumesMSA[route]);
//                System.out.println("***");
//
                timeThisIter[route] = getCongestedTime(freeFlow[route], capacity[route], volumesMSA[route]);
                System.out.println(routeNames[route]+","+volumesThisIter[route]+","+volumesMSA[route]+","+timeThisIter[route]);

                volumes[route] = volumesMSA[route];
                congestedTime[route] = timeThisIter[route];
            }
            if (iter == 1000000) equilibriumFound = true;
        } while (!equilibriumFound);


        System.out.println("Done in " + iter + " iterations.");
    }


    private static float[] getVolumesAON (float[] time) {
        // assign volumes in all-or-nothing assignment based on speed
        float totVol = demand;

        float[] volumes = new float[]{0f, 0f, 0f};
        if (rounder(time[0],1) == rounder(time[1],1) && rounder(time[0],1) == rounder(time[2],1)) {
            System.out.println("Equilibrium found.");
            System.exit(0);
            return null;
        } else if (time[0] == time[1]) {
            volumes[0] = totVol / 2f;
            volumes[1] = totVol / 2f;
            return volumes;
        } else if (time[1] == time[2]) {
            volumes[1] = totVol / 2f;
            volumes[2] = totVol / 2f;
            return volumes;
        } else {
            if (time[0] <= time[1] && time[0] <= time[2]) {
                volumes[0] = demand;
            } else if (time[1] <= time[0] && time[1] <= time[2]) {
                volumes[1] = demand;
            } else {
                volumes[2] = demand;
            }
            return volumes;
        }
    }


    private static float getCongestedTime(float ffSpeed, float capacity, float volume) {
        // apply volume-delay function to calculate congested travel time
        return ffSpeed * (1f + alpha * (float) Math.pow((volume/capacity), beta));
    }


    private static float rounder(float value, int digits) {
        // rounds value to digits behind the decimal point

        return Math.round(value * Math.pow(10, digits))/(float) Math.pow(10, digits);
    }
}

